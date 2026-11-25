import 'package:flutter/material.dart';

/// Centralized, unified icon system for VIORA.
///
/// Implements the exact bold, solid-filled, minimal geometric icon system
/// established in the VIORA Complete Icon Design System reference sheet.
class VioraIcons {
  VioraIcons._();

  // --- Row 1: Primary Navigation & Chrome ---
  // Home: Filled House
  static const IconData home = Icons.home_rounded;
  // Library: Filled Film Strip / Video
  static const IconData library = Icons.movie_rounded;
  // Collections: Filled Folder
  static const IconData collections = Icons.folder_rounded;
  // Settings: Filled Gear
  static const IconData settings = Icons.settings_rounded;
  // Search: Bold magnifying glass
  static const IconData search = Icons.search_rounded;
  // Back: Bold left arrow
  static const IconData back = Icons.arrow_back_rounded;
  // Forward: Bold right arrow
  static const IconData forward = Icons.arrow_forward_rounded;
  // Close: Bold X mark
  static const IconData close = Icons.close_rounded;
  static const IconData closeCircle = Icons.cancel_rounded;
  // More: Vertical 3 dots
  static const IconData more = Icons.more_vert_rounded;
  static const IconData moreHorizontal = Icons.more_horiz_rounded;
  static const IconData plus = Icons.add_rounded;
  static const IconData plusCircle = Icons.add_circle_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronDown = Icons.keyboard_arrow_down_rounded;
  static const IconData chevronUp = Icons.keyboard_arrow_up_rounded;
  static const IconData grid = Icons.grid_view_rounded;
  static const IconData list = Icons.format_list_bulleted_rounded;
  static const IconData sort = Icons.swap_vert_rounded;
  static const IconData scan = Icons.document_scanner_rounded;

  // --- Row 2: Video Player Controls ---
  // Play: Solid right-pointing triangle
  static const IconData play = Icons.play_arrow_rounded;
  // Pause: Solid two vertical bars
  static const IconData pause = Icons.pause_rounded;
  // Previous: Filled double triangle left with bar
  static const IconData previous = Icons.skip_previous_rounded;
  // Next: Filled double triangle right with bar
  static const IconData next = Icons.skip_next_rounded;
  // Seek Backward (10s): Double triangle left
  static const IconData seekBackward = Icons.fast_rewind_rounded;
  // Seek Forward (10s): Double triangle right
  static const IconData seekForward = Icons.fast_forward_rounded;
  // Fullscreen: 4 corner brackets expanding
  static const IconData fullscreen = Icons.fullscreen_rounded;
  // Exit Fullscreen: Exit fullscreen box/arrow
  static const IconData exitFullscreen = Icons.fullscreen_exit_rounded;
  // Lock: Solid closed padlock
  static const IconData lock = Icons.lock_rounded;

  // --- Row 3: Playback Adjustment Controls ---
  // Unlock: Solid open padlock
  static const IconData unlock = Icons.lock_open_rounded;
  // Volume: Speaker with soundwaves
  static const IconData volumeHigh = Icons.volume_up_rounded;
  static const IconData volumeMedium = Icons.volume_down_rounded;
  // Mute: Speaker with slash
  static const IconData volumeMute = Icons.volume_off_rounded;
  // Brightness: Sun with rays
  static const IconData brightness = Icons.wb_sunny_rounded;
  // Speed: Gauge / Speedometer
  static const IconData speed = Icons.speed_rounded;
  // Subtitles: CC rounded badge
  static const IconData subtitles = Icons.closed_caption_rounded;
  // Aspect Ratio: Screen rectangle with thick borders
  static const IconData aspectRatio = Icons.aspect_ratio_rounded;
  // Rotate: Phone rotation indicator
  static const IconData orientation = Icons.screen_rotation_rounded;
  // PIP: Picture in Picture overlapping windows
  static const IconData pip = Icons.picture_in_picture_alt_rounded;
  static const IconData scaling = Icons.fit_screen_rounded;

  // --- Row 4: Media, File & Action Controls ---
  // Video: Clapperboard with play triangle
  static const IconData video = Icons.movie_filter_rounded;
  // Folder: Solid folder
  static const IconData folder = Icons.folder_rounded;
  // Playlist: 3 horizontal lines with right arrow/play
  static const IconData playlist = Icons.playlist_play_rounded;
  // Audio Track: Musical note pair (eighth notes)
  static const IconData audioTrack = Icons.music_note_rounded;
  // Favorites: Solid heart
  static const IconData favorites = Icons.favorite_rounded;
  // History: Clock face with hands
  static const IconData recent = Icons.history_rounded;
  // Download: Arrow down into tray
  static const IconData download = Icons.file_download_rounded;
  // Share: Node branching network
  static const IconData share = Icons.share_rounded;
  // Edit: Angled pencil
  static const IconData edit = Icons.edit_rounded;

  // --- Row 5: Management & Privacy Controls ---
  // Delete: Trash can with vertical slots
  static const IconData delete = Icons.delete_rounded;
  // Rename: Pencil on document / edit square
  static const IconData rename = Icons.drive_file_rename_outline_rounded;
  // Info: Solid circle with "i"
  static const IconData info = Icons.info_rounded;
  // Privacy: Shield with checkmark
  static const IconData privacy = Icons.verified_user_rounded;
  static const IconData security = Icons.shield_rounded;
  // App Lock: Padlock with keyhole
  static const IconData appLock = Icons.lock_outline_rounded;
  // Biometric: Concentric fingerprint ridges
  static const IconData biometric = Icons.fingerprint_rounded;
  // Backup: Cloud with up arrow
  static const IconData backup = Icons.cloud_upload_rounded;
  // Restore: Cloud with down arrow
  static const IconData restore = Icons.cloud_download_rounded;
  // Vault: Safe dial / target concentric squares
  static const IconData vault = Icons.security_rounded;
  static const IconData privateFolder = Icons.folder_special_rounded;

  // --- Row 6: Support, Community & System Controls ---
  // Support: Coffee cup with steam
  static const IconData coffee = Icons.coffee_rounded;
  // Love: Solid heart
  static const IconData heart = Icons.favorite_rounded;
  // UPI Donate: Indian Rupee currency symbol
  static const IconData rupee = Icons.currency_rupee_rounded;
  static const IconData upiPayment = Icons.account_balance_wallet_rounded;
  // QR Code: 2D barcode matrix
  static const IconData qrCode = Icons.qr_code_2_rounded;
  // GitHub: Code / branch symbol
  static const IconData github = Icons.code_rounded;
  // About: Solid circle with "i"
  static const IconData about = Icons.info_rounded;
  // Help: Question mark inside solid circle
  static const IconData help = Icons.help_rounded;
  // Notifications: Bell
  static const IconData notifications = Icons.notifications_rounded;
  // Theme: Artist palette with color dots
  static const IconData theme = Icons.palette_rounded;
  static const IconData palette = Icons.palette_rounded;

  // --- Supplementary & Utility Icons ---
  static const IconData check = Icons.check_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData alert = Icons.warning_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData externalLink = Icons.open_in_new_rounded;
  static const IconData sparkles = Icons.auto_awesome_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData sun = Icons.light_mode_rounded;
  static const IconData moon = Icons.dark_mode_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData fileText = Icons.description_rounded;
  static const IconData filePlus = Icons.note_add_rounded;
  static const IconData storage = Icons.sd_storage_rounded;
  static const IconData permissions = Icons.security_rounded;
  static const IconData privacyEye = Icons.visibility_off_rounded;
  static const IconData offline = Icons.cloud_off_rounded;
  static const IconData ban = Icons.block_rounded;
  static const IconData heartHandshake = Icons.volunteer_activism_rounded;
  static const IconData supportDeveloper = Icons.favorite_rounded;
  static const IconData launch = Icons.open_in_new_rounded;
  static const IconData zap = Icons.bolt_rounded;
  static const IconData globe = Icons.public_rounded;
  static const IconData gitBranch = Icons.fork_right_rounded;
  static const IconData gitCommit = Icons.commit_rounded;
  static const IconData mail = Icons.mail_rounded;
  static const IconData hardware = Icons.memory_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData clapperboard = Icons.movie_filter_rounded;
  static const IconData fastForward = Icons.fast_forward_rounded;
  static const IconData rewind = Icons.fast_rewind_rounded;
}
