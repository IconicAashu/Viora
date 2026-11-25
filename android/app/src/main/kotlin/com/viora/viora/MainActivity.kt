package com.viora.viora

import android.Manifest
import android.app.Activity
import android.app.PictureInPictureParams
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.media.AudioManager
import android.media.MediaMetadataRetriever
import android.media.MediaScannerConnection
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.os.CancellationSignal
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.provider.Settings
import android.util.Log
import android.util.LongSparseArray
import android.util.Rational
import android.util.Size
import android.view.WindowManager
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.media3.common.C
import androidx.media3.common.Format
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.text.CueGroup
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {
    private val PERMISSIONS_CHANNEL = "com.viora.viora/permissions"
    private val PIP_CHANNEL = "com.viora.viora/pip"
    private val MEDIASTORE_CHANNEL = "com.viora.viora/mediastore"
    private val PLAYER_CONTROLS_CHANNEL = "com.viora.viora/player_controls"
    private val BIOMETRICS_CHANNEL = "com.viora.viora/biometrics"
    private val VAULT_CHANNEL = "com.viora.viora/vault"
    private val APP_UPDATE_CHANNEL = "com.viora.viora/app_update"
    private val TRACKS_CHANNEL = "com.viora.viora/tracks"
    private val UPI_CHANNEL = "com.viora.viora/upi"

    private val PERMISSION_REQUEST_CODE = 1001
    private val SUBTITLE_PICKER_REQUEST_CODE = 2002
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingSubtitleResult: MethodChannel.Result? = null
    private val scope = CoroutineScope(Dispatchers.Main)

    private var tracksChannel: MethodChannel? = null
    private var attachedExoPlayer: ExoPlayer? = null

    private val playerListener = object : Player.Listener {
        override fun onCues(cueGroup: CueGroup) {
            val textBuilder = StringBuilder()
            for (cue in cueGroup.cues) {
                if (!cue.text.isNullOrEmpty()) {
                    if (textBuilder.isNotEmpty()) textBuilder.append("\n")
                    textBuilder.append(cue.text)
                }
            }
            runOnUiThread {
                tracksChannel?.invokeMethod("onSubtitleCue", mapOf("text" to textBuilder.toString()))
            }
        }

        override fun onTracksChanged(tracks: Tracks) {
            runOnUiThread {
                tracksChannel?.invokeMethod("onTracksChanged", null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Permissions Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkVideoPermission" -> {
                    result.success(checkMediaVideoPermission())
                }
                "requestVideoPermission" -> {
                    val status = checkMediaVideoPermission()
                    if (status == 1) {
                        result.success(1)
                    } else {
                        pendingPermissionResult = result
                        requestMediaVideoPermission()
                    }
                }
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", packageName, null)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Picture-in-Picture Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> {
                    val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
                    result.success(supported)
                }
                "enterPip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
                    ) {
                        try {
                            val aspectRatio = call.argument<Double>("aspectRatio") ?: (16.0 / 9.0)
                            val clamped = aspectRatio.coerceIn(0.42, 2.38)
                            val rational = Rational((clamped * 100).toInt(), 100)
                            val params = PictureInPictureParams.Builder()
                                .setAspectRatio(rational)
                                .build()
                            val entered = enterPictureInPictureMode(params)
                            result.success(entered)
                        } catch (e: Exception) {
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 3. MediaStore Video Discovery Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIASTORE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanVideos" -> {
                    val minDurationMs = call.argument<Int>("minDurationMs") ?: 1000
                    scope.launch {
                        try {
                            val videos = withContext(Dispatchers.IO) {
                                queryDeviceVideos(minDurationMs)
                            }
                            result.success(videos)
                        } catch (e: Exception) {
                            result.error("SCAN_ERROR", e.message, null)
                        }
                    }
                }
                "generateThumbnail" -> {
                    val filePath = call.argument<String>("filePath") ?: ""
                    val videoId = call.argument<String>("videoId") ?: ""
                    scope.launch {
                        val thumbPath = withContext(Dispatchers.IO) {
                            getVideoThumbnail(filePath, videoId)
                        }
                        result.success(thumbPath)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 4. Hardware Player Controls (Brightness & Volume)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLAYER_CONTROLS_CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "setBrightness" -> {
                    val level = call.argument<Double>("level")?.toFloat() ?: -1f
                    val lp = window.attributes
                    lp.screenBrightness = if (level < 0f) WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE else level.coerceIn(0.01f, 1f)
                    window.attributes = lp
                    result.success(true)
                }
                "getBrightness" -> {
                    val lp = window.attributes
                    result.success(lp.screenBrightness.toDouble())
                }
                "setVolume" -> {
                    val level = call.argument<Double>("level") ?: 0.5
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val targetVolume = (level * maxVolume).toInt().coerceIn(0, maxVolume)
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
                    result.success(true)
                }
                "getVolume" -> {
                    val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val ratio = if (max > 0) current.toDouble() / max.toDouble() else 0.0
                    result.success(ratio)
                }
                else -> result.notImplemented()
            }
        }

        // 5. Biometric Authentication Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BIOMETRICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canAuthenticate" -> {
                    val biometricManager = BiometricManager.from(this)
                    val authenticators = BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL
                    val canAuth = biometricManager.canAuthenticate(authenticators) == BiometricManager.BIOMETRIC_SUCCESS
                    result.success(canAuth)
                }
                "authenticate" -> {
                    val title = call.argument<String>("title") ?: "Unlock VIORA"
                    val subtitle = call.argument<String>("subtitle") ?: "Confirm your biometric credential"

                    val executor = ContextCompat.getMainExecutor(this)
                    val prompt = BiometricPrompt(this, executor, object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                            super.onAuthenticationSucceeded(authResult)
                            result.success(true)
                        }

                        override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                            super.onAuthenticationError(errorCode, errString)
                            result.success(false)
                        }

                        override fun onAuthenticationFailed() {
                            super.onAuthenticationFailed()
                        }
                    })

                    val promptInfo = BiometricPrompt.PromptInfo.Builder()
                        .setTitle(title)
                        .setSubtitle(subtitle)
                        .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL)
                        .build()

                    prompt.authenticate(promptInfo)
                }
                else -> result.notImplemented()
            }
        }

        // 6. Private Vault (Secure storage / File Protection)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VAULT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hideVideo" -> {
                    val sourcePath = call.argument<String>("filePath") ?: ""
                    val videoId = call.argument<String>("videoId") ?: ""
                    scope.launch {
                        val destinationPath = withContext(Dispatchers.IO) {
                            moveToVault(sourcePath, videoId)
                        }
                        result.success(destinationPath)
                    }
                }
                "unhideVideo" -> {
                    val vaultPath = call.argument<String>("vaultPath") ?: ""
                    val originalTarget = call.argument<String>("originalPath") ?: ""
                    scope.launch {
                        val restoredPath = withContext(Dispatchers.IO) {
                            restoreFromVault(vaultPath, originalTarget)
                        }
                        result.success(restoredPath)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 7. App Update Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_UPDATE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canInstallPackages" -> {
                    val canInstall = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        packageManager.canRequestPackageInstalls()
                    } else {
                        true
                    }
                    result.success(canInstall)
                }
                "openInstallPermissionSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_PATH", "APK file path cannot be null", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val apkFile = File(filePath)
                        if (!apkFile.exists()) {
                            result.error("FILE_NOT_FOUND", "APK file does not exist at $filePath", null)
                            return@setMethodCallHandler
                        }
                        val contentUri = androidx.core.content.FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            apkFile
                        )
                        val installIntent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(contentUri, "application/vnd.android.package-archive")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
                        }
                        startActivity(installIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 8. Media3 Audio and Subtitle Tracks Channel
        tracksChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRACKS_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAudioTracks" -> {
                        try {
                            val tracks = getAudioTracks()
                            result.success(tracks)
                        } catch (e: Exception) {
                            result.error("AUDIO_TRACKS_ERROR", e.message, null)
                        }
                    }
                    "selectAudioTrack" -> {
                        val groupIndex = call.argument<Int>("groupIndex") ?: -1
                        val trackIndex = call.argument<Int>("trackIndex") ?: -1
                        val success = selectAudioTrack(groupIndex, trackIndex)
                        result.success(success)
                    }
                    "resetAudioTrack" -> {
                        val success = resetAudioTrack()
                        result.success(success)
                    }
                    "getSubtitleTracks" -> {
                        try {
                            val tracks = getSubtitleTracks()
                            result.success(tracks)
                        } catch (e: Exception) {
                            result.error("SUBTITLE_TRACKS_ERROR", e.message, null)
                        }
                    }
                    "selectSubtitleTrack" -> {
                        val groupIndex = call.argument<Int>("groupIndex") ?: -1
                        val trackIndex = call.argument<Int>("trackIndex") ?: -1
                        val success = selectSubtitleTrack(groupIndex, trackIndex)
                        result.success(success)
                    }
                    "disableSubtitles" -> {
                        val success = disableSubtitles()
                        result.success(success)
                    }
                    "pickSubtitleFile" -> {
                        pickSubtitleFile(result)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        // 9. UPI Donation Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPI_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUpi" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr.isNullOrEmpty()) {
                        result.error("INVALID_URI", "UPI URI cannot be null or empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            data = Uri.parse(uriStr)
                        }
                        val resolveInfos = packageManager.queryIntentActivities(intent, 0)
                        if (resolveInfos.isEmpty()) {
                            result.success(mapOf("launched" to false, "reason" to "NO_UPI_APP"))
                        } else {
                            val chooser = Intent.createChooser(intent, "Pay via UPI App")
                            startActivity(chooser)
                            result.success(mapOf("launched" to true))
                        }
                    } catch (e: Exception) {
                        result.error("LAUNCH_ERROR", e.message, null)
                    }
                }
                "checkUpiAvailable" -> {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse("upi://pay")
                    }
                    val resolveInfos = packageManager.queryIntentActivities(intent, 0)
                    result.success(resolveInfos.isNotEmpty())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getActiveExoPlayer(): ExoPlayer? {
        try {
            @Suppress("UNCHECKED_CAST")
            val pluginClass = Class.forName("io.flutter.plugins.videoplayer.VideoPlayerPlugin") as Class<out io.flutter.embedding.engine.plugins.FlutterPlugin>
            val plugin = flutterEngine?.plugins?.get(pluginClass) ?: return null
            val field = plugin.javaClass.getDeclaredField("videoPlayers").apply { isAccessible = true }
            val sparseArray = field.get(plugin) as? LongSparseArray<*> ?: return null
            if (sparseArray.size() > 0) {
                val videoPlayerObj = sparseArray.valueAt(sparseArray.size() - 1) ?: return null
                var clazz: Class<*>? = videoPlayerObj.javaClass
                while (clazz != null && clazz != Any::class.java) {
                    try {
                        val exoField = clazz.getDeclaredField("exoPlayer").apply { isAccessible = true }
                        val player = exoField.get(videoPlayerObj) as? ExoPlayer
                        if (player != null) {
                            if (attachedExoPlayer != player) {
                                attachedExoPlayer?.removeListener(playerListener)
                                attachedExoPlayer = player
                                player.addListener(playerListener)
                            }
                            return player
                        }
                    } catch (_: NoSuchFieldException) {
                        clazz = clazz.superclass
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("VIORA_TRACKS", "Error retrieving active ExoPlayer instance: ${e.message}")
        }
        return null
    }

    private fun getAudioTracks(): List<Map<String, Any?>> {
        val player = getActiveExoPlayer() ?: return emptyList()
        val trackList = mutableListOf<Map<String, Any?>>()
        val tracks = player.currentTracks

        for (groupIndex in 0 until tracks.groups.size) {
            val group = tracks.groups[groupIndex]
            if (group.type == C.TRACK_TYPE_AUDIO) {
                for (trackIndex in 0 until group.length) {
                    val format = group.getTrackFormat(trackIndex)
                    val isSelected = group.isTrackSelected(trackIndex)
                    val isSupported = group.isTrackSupported(trackIndex)

                    val langCode = format.language ?: ""
                    val langDisplay = if (langCode.isNotEmpty()) {
                        try {
                            Locale(langCode).getDisplayLanguage(Locale.ENGLISH).replaceFirstChar { it.uppercase() }
                        } catch (_: Exception) {
                            langCode
                        }
                    } else ""

                    val codec = formatCodec(format.sampleMimeType)
                    val channels = formatChannels(format.channelCount)

                    val label = when {
                        !format.label.isNullOrEmpty() -> format.label!!
                        langDisplay.isNotEmpty() -> langDisplay
                        else -> "Audio Track ${trackList.size + 1}"
                    }

                    trackList.add(mapOf(
                        "id" to "${groupIndex}_$trackIndex",
                        "groupIndex" to groupIndex,
                        "trackIndex" to trackIndex,
                        "label" to label,
                        "language" to langDisplay,
                        "langCode" to langCode,
                        "codec" to codec,
                        "channels" to channels,
                        "bitrate" to format.bitrate,
                        "isSelected" to isSelected,
                        "isSupported" to isSupported
                    ))
                }
            }
        }
        return trackList
    }

    private fun formatCodec(mimeType: String?): String {
        if (mimeType == null) return "Unknown"
        return when {
            mimeType.contains("mp4a-latm", ignoreCase = true) -> "AAC"
            mimeType.contains("ac3", ignoreCase = true) && !mimeType.contains("eac3", ignoreCase = true) -> "AC3"
            mimeType.contains("eac3", ignoreCase = true) -> "E-AC3"
            mimeType.contains("dts", ignoreCase = true) -> "DTS"
            mimeType.contains("true-hd", ignoreCase = true) -> "TrueHD"
            mimeType.contains("opus", ignoreCase = true) -> "Opus"
            mimeType.contains("vorbis", ignoreCase = true) -> "Vorbis"
            mimeType.contains("flac", ignoreCase = true) -> "FLAC"
            mimeType.contains("mpeg", ignoreCase = true) -> "MP3"
            else -> mimeType.substringAfterLast("/").uppercase()
        }
    }

    private fun formatChannels(channelCount: Int): String {
        return when (channelCount) {
            1 -> "1.0 Mono"
            2 -> "2.0 Stereo"
            6 -> "5.1 Surround"
            8 -> "7.1 Surround"
            else -> if (channelCount > 0) "$channelCount Channels" else ""
        }
    }

    private fun selectAudioTrack(groupIndex: Int, trackIndex: Int): Boolean {
        val player = getActiveExoPlayer() ?: return false
        val tracks = player.currentTracks
        if (groupIndex in 0 until tracks.groups.size) {
            val group = tracks.groups[groupIndex]
            val override = TrackSelectionOverride(group.mediaTrackGroup, trackIndex)
            val newParams = player.trackSelectionParameters
                .buildUpon()
                .setOverrideForType(override)
                .build()
            player.trackSelectionParameters = newParams
            return true
        }
        return false
    }

    private fun resetAudioTrack(): Boolean {
        val player = getActiveExoPlayer() ?: return false
        val newParams = player.trackSelectionParameters
            .buildUpon()
            .clearOverridesOfType(C.TRACK_TYPE_AUDIO)
            .build()
        player.trackSelectionParameters = newParams
        return true
    }

    private fun getSubtitleTracks(): List<Map<String, Any?>> {
        val player = getActiveExoPlayer() ?: return emptyList()
        val trackList = mutableListOf<Map<String, Any?>>()
        val tracks = player.currentTracks

        for (groupIndex in 0 until tracks.groups.size) {
            val group = tracks.groups[groupIndex]
            if (group.type == C.TRACK_TYPE_TEXT) {
                for (trackIndex in 0 until group.length) {
                    val format = group.getTrackFormat(trackIndex)
                    val isSelected = group.isTrackSelected(trackIndex)

                    val langCode = format.language ?: ""
                    val langDisplay = if (langCode.isNotEmpty()) {
                        try {
                            Locale(langCode).getDisplayLanguage(Locale.ENGLISH).replaceFirstChar { it.uppercase() }
                        } catch (_: Exception) {
                            langCode
                        }
                    } else ""

                    val label = when {
                        !format.label.isNullOrEmpty() -> format.label!!
                        langDisplay.isNotEmpty() -> langDisplay
                        else -> "Subtitle ${trackList.size + 1}"
                    }

                    trackList.add(mapOf(
                        "id" to "${groupIndex}_$trackIndex",
                        "groupIndex" to groupIndex,
                        "trackIndex" to trackIndex,
                        "label" to label,
                        "language" to langDisplay,
                        "langCode" to langCode,
                        "mimeType" to (format.sampleMimeType ?: ""),
                        "isSelected" to isSelected,
                        "isExternal" to false
                    ))
                }
            }
        }
        return trackList
    }

    private fun selectSubtitleTrack(groupIndex: Int, trackIndex: Int): Boolean {
        val player = getActiveExoPlayer() ?: return false
        val tracks = player.currentTracks
        if (groupIndex in 0 until tracks.groups.size) {
            val group = tracks.groups[groupIndex]
            val override = TrackSelectionOverride(group.mediaTrackGroup, trackIndex)
            val newParams = player.trackSelectionParameters
                .buildUpon()
                .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, false)
                .setOverrideForType(override)
                .build()
            player.trackSelectionParameters = newParams
            return true
        }
        return false
    }

    private fun disableSubtitles(): Boolean {
        val player = getActiveExoPlayer() ?: return false
        val newParams = player.trackSelectionParameters
            .buildUpon()
            .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, true)
            .clearOverridesOfType(C.TRACK_TYPE_TEXT)
            .build()
        player.trackSelectionParameters = newParams
        tracksChannel?.invokeMethod("onSubtitleCue", mapOf("text" to ""))
        return true
    }

    private fun pickSubtitleFile(result: MethodChannel.Result) {
        pendingSubtitleResult = result
        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                    "text/plain",
                    "text/vtt",
                    "application/x-subrip",
                    "application/octet-stream"
                ))
            }
            startActivityForResult(intent, SUBTITLE_PICKER_REQUEST_CODE)
        } catch (e: Exception) {
            pendingSubtitleResult?.error("PICKER_ERROR", e.message, null)
            pendingSubtitleResult = null
        }
    }

    private fun getRequiredPermission(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_VIDEO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
    }

    private fun checkMediaVideoPermission(): Int {
        val permission = getRequiredPermission()
        val granted = ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        return if (granted) 1 else 2
    }

    private fun requestMediaVideoPermission() {
        val permission = getRequiredPermission()
        ActivityCompat.requestPermissions(this, arrayOf(permission), PERMISSION_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val isGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(if (isGranted) 1 else 2)
            pendingPermissionResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SUBTITLE_PICKER_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                scope.launch {
                    try {
                        var fileName = "subtitle.srt"
                        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                            if (nameIndex >= 0 && cursor.moveToFirst()) {
                                fileName = cursor.getString(nameIndex) ?: "subtitle.srt"
                            }
                        }

                        val content = withContext(Dispatchers.IO) {
                            contentResolver.openInputStream(uri)?.use { stream ->
                                stream.bufferedReader().readText()
                            } ?: ""
                        }

                        pendingSubtitleResult?.success(mapOf(
                            "fileName" to fileName,
                            "uri" to uri.toString(),
                            "content" to content
                        ))
                    } catch (e: Exception) {
                        pendingSubtitleResult?.error("READ_ERROR", e.message, null)
                    } finally {
                        pendingSubtitleResult = null
                    }
                }
            } else {
                pendingSubtitleResult?.success(null)
                pendingSubtitleResult = null
            }
        }
    }

    // MediaStore Query Implementation
    private fun queryDeviceVideos(minDurationMs: Int): List<Map<String, Any?>> {
        val videoList = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.TITLE,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATE_ADDED,
            MediaStore.Video.Media.DATE_MODIFIED,
            MediaStore.Video.Media.MIME_TYPE,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.BUCKET_ID,
            MediaStore.Video.Media.BUCKET_DISPLAY_NAME
        )

        val selection = "${MediaStore.Video.Media.SIZE} > 0 AND ${MediaStore.Video.Media.DURATION} >= ?"
        val selectionArgs = arrayOf(minDurationMs.toString())
        val sortOrder = "${MediaStore.Video.Media.DATE_MODIFIED} DESC"

        val cursor = contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )

        cursor?.use {
            val idCol = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val dataCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
            val nameCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
            val titleCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE)
            val durCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
            val sizeCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
            val dateAddCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED)
            val dateModCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED)
            val mimeCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.MIME_TYPE)
            val widthCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.WIDTH)
            val heightCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.HEIGHT)
            val bucketIdCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.BUCKET_ID)
            val bucketNameCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)

            while (it.moveToNext()) {
                val filePath = it.getString(dataCol)
                // Skip inaccessible or deleted files
                if (filePath.isNullOrEmpty() || !File(filePath).exists()) continue

                val id = it.getLong(idCol).toString()
                val displayName = it.getString(nameCol) ?: "Video"
                val title = it.getString(titleCol) ?: displayName
                val duration = it.getLong(durCol)
                val size = it.getLong(sizeCol)
                val dateAddedSec = it.getLong(dateAddCol)
                val dateModSec = it.getLong(dateModCol)
                val mime = it.getString(mimeCol) ?: "video/*"
                val width = it.getInt(widthCol)
                val height = it.getInt(heightCol)
                val bucketId = it.getString(bucketIdCol) ?: "default"
                val bucketName = it.getString(bucketNameCol) ?: "Videos"

                // Create and cache thumbnail if available
                val thumbnailPath = getVideoThumbnail(filePath, id)

                val videoMap = mapOf<String, Any?>(
                    "id" to id,
                    "filePath" to filePath,
                    "title" to title,
                    "durationMs" to duration,
                    "sizeBytes" to size,
                    "dateAddedMs" to (dateAddedSec * 1000),
                    "dateModifiedMs" to (dateModSec * 1000),
                    "mimeType" to mime,
                    "width" to width,
                    "height" to height,
                    "bucketId" to bucketId,
                    "bucketDisplayName" to bucketName,
                    "thumbnailPath" to thumbnailPath
                )
                videoList.add(videoMap)
            }
        }
        return videoList
    }

    private fun getVideoThumbnail(filePath: String, videoId: String): String? {
        val thumbDir = File(cacheDir, "viora_thumbnails")
        if (!thumbDir.exists()) thumbDir.mkdirs()
        val thumbFile = File(thumbDir, "thumb_$videoId.jpg")
        if (thumbFile.exists() && thumbFile.length() > 0) {
            return thumbFile.absolutePath
        }

        val videoUri: Uri? = try {
            val idLong = videoId.toLongOrNull()
            if (idLong != null) {
                ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, idLong)
            } else null
        } catch (_: Exception) { null }

        var bitmap: Bitmap? = null

        // Strategy 1: ContentResolver.loadThumbnail (Android 10+ recommended MediaStore API)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && videoUri != null) {
            try {
                bitmap = contentResolver.loadThumbnail(videoUri, Size(512, 288), CancellationSignal())
            } catch (_: Exception) {}
        }

        // Strategy 2: MediaMetadataRetriever (works for direct file paths, Content URIs, MP4, MKV, WebM)
        if (bitmap == null) {
            var retriever: MediaMetadataRetriever? = null
            try {
                retriever = MediaMetadataRetriever()
                if (videoUri != null) {
                    try {
                        retriever.setDataSource(applicationContext, videoUri)
                    } catch (_: Exception) {
                        if (filePath.isNotEmpty() && File(filePath).exists()) {
                            retriever.setDataSource(filePath)
                        }
                    }
                } else if (filePath.isNotEmpty() && File(filePath).exists()) {
                    retriever.setDataSource(filePath)
                }

                // Extract frame around 1000ms (1 second) or first keyframe
                bitmap = retriever.getFrameAtTime(1000000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                if (bitmap == null) {
                    bitmap = retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                }
            } catch (_: Exception) {
            } finally {
                try {
                    retriever?.release()
                } catch (_: Exception) {}
            }
        }

        // Strategy 3: ThumbnailUtils.createVideoThumbnail (File-based)
        if (bitmap == null && filePath.isNotEmpty() && File(filePath).exists()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    bitmap = ThumbnailUtils.createVideoThumbnail(File(filePath), Size(512, 288), CancellationSignal())
                } catch (_: Exception) {}
            }
            if (bitmap == null) {
                @Suppress("DEPRECATION")
                try {
                    bitmap = ThumbnailUtils.createVideoThumbnail(filePath, MediaStore.Images.Thumbnails.MINI_KIND)
                } catch (_: Exception) {}
            }
        }

        if (bitmap != null) {
            try {
                FileOutputStream(thumbFile).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
                }
                bitmap.recycle()
                return thumbFile.absolutePath
            } catch (_: Exception) {}
        }

        return null
    }

    // Vault Implementation: Actual file relocation into application private sandbox
    private fun moveToVault(sourcePath: String, videoId: String): String? {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) return null

        val vaultDir = File(filesDir, "viora_vault")
        if (!vaultDir.exists()) vaultDir.mkdirs()

        val ext = sourceFile.extension.ifEmpty { "mp4" }
        val targetFile = File(vaultDir, "vault_${videoId}.$ext")

        // Copy file into private internal storage
        FileInputStream(sourceFile).use { input ->
            FileOutputStream(targetFile).use { output ->
                input.copyTo(output)
            }
        }

        if (targetFile.exists() && targetFile.length() == sourceFile.length()) {
            // Attempt delete from public storage and refresh media scanner
            try {
                sourceFile.delete()
                MediaScannerConnection.scanFile(this, arrayOf(sourcePath), null, null)
            } catch (_: Exception) {}
            return targetFile.absolutePath
        }
        return null
    }

    private fun restoreFromVault(vaultPath: String, originalTarget: String): String? {
        val vaultFile = File(vaultPath)
        if (!vaultFile.exists()) return null

        var destination = File(originalTarget)
        if (!destination.parentFile.exists()) {
            // Fallback to Movies directory if original path folder no longer exists
            val moviesDir = File(android.os.Environment.getExternalStorageDirectory(), "Movies/VIORA")
            if (!moviesDir.exists()) moviesDir.mkdirs()
            destination = File(moviesDir, vaultFile.name.replace("vault_", "restored_"))
        }

        FileInputStream(vaultFile).use { input ->
            FileOutputStream(destination).use { output ->
                input.copyTo(output)
            }
        }

        if (destination.exists() && destination.length() == vaultFile.length()) {
            vaultFile.delete()
            MediaScannerConnection.scanFile(this, arrayOf(destination.absolutePath), null, null)
            return destination.absolutePath
        }
        return null
    }

    override fun onDestroy() {
        attachedExoPlayer?.removeListener(playerListener)
        attachedExoPlayer = null
        super.onDestroy()
    }
}
