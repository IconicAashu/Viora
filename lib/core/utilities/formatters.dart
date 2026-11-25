abstract final class Formatters {
  /// Formats milliseconds into a readable video duration (HH:MM:SS or MM:SS).
  static String formatDuration(int milliseconds) {
    if (milliseconds <= 0) return '0:00';

    final totalSeconds = (milliseconds / 1000).round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final minutesStr = minutes.toString().padLeft(2, '0');
      return '$hours:$minutesStr:$secondsStr';
    } else {
      return '$minutes:$secondsStr';
    }
  }

  /// Formats byte sizes into human-readable strings (e.g., 250 MB, 1.4 GB).
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int digitGroups = 0;
    double size = bytes.toDouble();

    while (size >= 1024.0 && digitGroups < units.length - 1) {
      size /= 1024.0;
      digitGroups++;
    }

    if (digitGroups == 0) {
      return '${size.toInt()} ${units[digitGroups]}';
    } else {
      return '${size.toStringAsFixed(1)} ${units[digitGroups]}';
    }
  }

  /// Formats resolution string into concise quality badge (e.g., 4K, 1080p, 720p).
  static String formatResolution(int? width, int? height) {
    if (width == null || height == null || width == 0 || height == 0) return '';

    final minDim = width < height ? width : height;
    final maxDim = width > height ? width : height;

    if (maxDim >= 3840 || minDim >= 2160) return '4K';
    if (maxDim >= 2560 || minDim >= 1440) return '2K';
    if (minDim >= 1080) return '1080p';
    if (minDim >= 720) return '720p';
    if (minDim >= 480) return '480p';
    return '${minDim}p';
  }

  /// Formats date into readable string (e.g., Nov 24, 2026).
  static String formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
