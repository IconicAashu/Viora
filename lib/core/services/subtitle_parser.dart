class SubtitleCue {
  final int startMs;
  final int endMs;
  final String text;

  const SubtitleCue({
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  bool matches(int positionMs) => positionMs >= startMs && positionMs <= endMs;

  @override
  String toString() => 'SubtitleCue($startMs..$endMs: "$text")';
}

/// Robust parser for .srt, .vtt, .ass, and .ssa subtitle files.
class SubtitleParser {
  /// Parse subtitle file content into a sorted list of [SubtitleCue]s.
  static List<SubtitleCue> parse(String content, {String? extension}) {
    final cleanContent = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final ext = extension?.toLowerCase().replaceAll('.', '') ?? '';

    if (ext == 'ass' || ext == 'ssa' || cleanContent.contains('[Events]')) {
      return _parseAss(cleanContent);
    } else if (ext == 'vtt' || cleanContent.startsWith('WEBVTT')) {
      return _parseVtt(cleanContent);
    } else {
      // Default to SRT parser (also handles loose VTT/SRT formats)
      return _parseSrt(cleanContent);
    }
  }

  /// Finds the active subtitle text at [positionMs], or null if none active.
  static String? getActiveCueText(List<SubtitleCue> cues, int positionMs) {
    if (cues.isEmpty) return null;

    // Binary search for efficiency
    int low = 0;
    int high = cues.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final cue = cues[mid];

      if (positionMs < cue.startMs) {
        high = mid - 1;
      } else if (positionMs > cue.endMs) {
        low = mid + 1;
      } else {
        return cue.text;
      }
    }

    // Fallback linear check for overlapping cues near mid
    for (int i = (low - 2).clamp(0, cues.length - 1); i <= (low + 2).clamp(0, cues.length - 1); i++) {
      if (cues[i].matches(positionMs)) {
        return cues[i].text;
      }
    }

    return null;
  }

  /// Parses SubRip (.srt) format
  static List<SubtitleCue> _parseSrt(String content) {
    final cues = <SubtitleCue>[];
    final blocks = content.split(RegExp(r'\n\s*\n'));

    final timeRegex = RegExp(r'(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})');

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;

      int timeLineIndex = -1;
      Match? match;

      for (int i = 0; i < lines.length; i++) {
        match = timeRegex.firstMatch(lines[i]);
        if (match != null) {
          timeLineIndex = i;
          break;
        }
      }

      if (match == null || timeLineIndex == -1) continue;

      final startMs = _parseTimestamp(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      );

      final endMs = _parseTimestamp(
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        int.parse(match.group(7)!),
        int.parse(match.group(8)!),
      );

      final textLines = lines.sublist(timeLineIndex + 1);
      final rawText = textLines.join('\n').trim();
      final cleanText = _stripMarkup(rawText);

      if (cleanText.isNotEmpty && endMs > startMs) {
        cues.add(SubtitleCue(startMs: startMs, endMs: endMs, text: cleanText));
      }
    }

    cues.sort((a, b) => a.startMs.compareTo(b.startMs));
    return cues;
  }

  /// Parses WebVTT (.vtt) format
  static List<SubtitleCue> _parseVtt(String content) {
    final cues = <SubtitleCue>[];
    final blocks = content.split(RegExp(r'\n\s*\n'));

    // Matches both 00:01:23.456 and 01:23.456
    final timeRegex = RegExp(
      r'(?:(\d{1,2}):)?(\d{2}):(\d{2})[.](\d{3})\s*-->\s*(?:(\d{1,2}):)?(\d{2}):(\d{2})[.](\d{3})',
    );

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      int timeLineIndex = -1;
      Match? match;

      for (int i = 0; i < lines.length; i++) {
        match = timeRegex.firstMatch(lines[i]);
        if (match != null) {
          timeLineIndex = i;
          break;
        }
      }

      if (match == null || timeLineIndex == -1) continue;

      final startH = match.group(1) != null ? int.parse(match.group(1)!) : 0;
      final startM = int.parse(match.group(2)!);
      final startS = int.parse(match.group(3)!);
      final startMsVal = int.parse(match.group(4)!);
      final startMs = _parseTimestamp(startH, startM, startS, startMsVal);

      final endH = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final endM = int.parse(match.group(6)!);
      final endS = int.parse(match.group(7)!);
      final endMsVal = int.parse(match.group(8)!);
      final endMs = _parseTimestamp(endH, endM, endS, endMsVal);

      final textLines = lines.sublist(timeLineIndex + 1);
      final rawText = textLines.join('\n').trim();
      final cleanText = _stripMarkup(rawText);

      if (cleanText.isNotEmpty && endMs > startMs) {
        cues.add(SubtitleCue(startMs: startMs, endMs: endMs, text: cleanText));
      }
    }

    cues.sort((a, b) => a.startMs.compareTo(b.startMs));
    return cues;
  }

  /// Parses SubStation Alpha (.ass / .ssa) format
  static List<SubtitleCue> _parseAss(String content) {
    final cues = <SubtitleCue>[];
    final lines = content.split('\n');
    final dialogRegex = RegExp(r'^Dialogue:\s*[^,]*,\s*(\d+):(\d{2}):(\d{2})\.(\d{2}),\s*(\d+):(\d{2}):(\d{2})\.(\d{2}),(.*)$');

    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('Dialogue:')) continue;

      final match = dialogRegex.firstMatch(trimmed);
      if (match == null) continue;

      final startH = int.parse(match.group(1)!);
      final startM = int.parse(match.group(2)!);
      final startS = int.parse(match.group(3)!);
      final startCenti = int.parse(match.group(4)!);
      final startMs = _parseTimestamp(startH, startM, startS, startCenti * 10);

      final endH = int.parse(match.group(5)!);
      final endM = int.parse(match.group(6)!);
      final endS = int.parse(match.group(7)!);
      final endCenti = int.parse(match.group(8)!);
      final endMs = _parseTimestamp(endH, endM, endS, endCenti * 10);

      final rest = match.group(9)!;
      // In ASS Dialogue format: Style, Name, MarginL, MarginR, MarginV, Effect, Text
      // The text is the 7th field in `rest` (after 6 commas)
      final parts = rest.split(',');
      final text = parts.length >= 7 ? parts.sublist(6).join(',') : rest;

      // Clean ASS override tags like {\an8}, {\b1}, \N (line breaks)
      var cleanText = text.replaceAll(RegExp(r'\{[^}]*\}'), '');
      cleanText = cleanText.replaceAll(RegExp(r'\\[Nn]'), '\n').trim();

      if (cleanText.isNotEmpty && endMs > startMs) {
        cues.add(SubtitleCue(startMs: startMs, endMs: endMs, text: cleanText));
      }
    }

    cues.sort((a, b) => a.startMs.compareTo(b.startMs));
    return cues;
  }

  static int _parseTimestamp(int hours, int minutes, int seconds, int milliseconds) {
    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + milliseconds;
  }

  static String _stripMarkup(String text) {
    // Strip HTML tags like <i>, <b>, <font color="...">, etc.
    var result = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Strip WebVTT timestamp tags like <00:19.000>
    result = result.replaceAll(RegExp(r'<\d{2}:\d{2}\.\d{3}>'), '');
    return result.trim();
  }
}
