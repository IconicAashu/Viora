import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/upi_donation_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_card.dart';

enum DonationPreset {
  any('Any Amount', null, 'Enter in UPI app', VioraIcons.sparkles),
  coffee('₹49', 49.0, 'Buy Me a Coffee', VioraIcons.coffee),
  love('₹99', 99.0, 'Show Some Love', VioraIcons.heart),
  support('₹199', 199.0, 'Support Development', VioraIcons.zap),
  custom('Custom', null, 'Your choice', VioraIcons.settings);

  const DonationPreset(this.label, this.amount, this.subtitle, this.icon);
  final String label;
  final double? amount;
  final String subtitle;
  final IconData icon;
}

class SupportVioraScreen extends ConsumerStatefulWidget {
  const SupportVioraScreen({super.key});

  @override
  ConsumerState<SupportVioraScreen> createState() => _SupportVioraScreenState();
}

class _SupportVioraScreenState extends ConsumerState<SupportVioraScreen>
    with WidgetsBindingObserver {
  DonationPreset _selectedPreset = DonationPreset.coffee;
  final TextEditingController _customAmountController = TextEditingController();
  final FocusNode _customAmountFocusNode = FocusNode();
  String? _customAmountError;

  bool _hasLaunchedPayment = false;
  bool _isQrExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customAmountController.dispose();
    _customAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasLaunchedPayment) {
      _hasLaunchedPayment = false;
      _showThankYouSheet();
    }
  }

  double? get _currentEffectiveAmount {
    if (_selectedPreset == DonationPreset.custom) {
      final text = _customAmountController.text.trim();
      final val = double.tryParse(text);
      if (val != null && val > 0) return val;
      return null;
    }
    return _selectedPreset.amount;
  }

  String get _currentUpiUri {
    return UpiDonationService.generateUpiUri(
      amount: _currentEffectiveAmount,
    );
  }

  void _onPresetSelected(DonationPreset preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != DonationPreset.custom) {
        _customAmountError = null;
        _customAmountFocusNode.unfocus();
      } else {
        _customAmountFocusNode.requestFocus();
      }
    });
  }

  void _validateCustomAmount(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      setState(() => _customAmountError = null);
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      setState(() => _customAmountError = 'Enter a valid amount (e.g. 50)');
    } else if (parsed > 100000) {
      setState(() => _customAmountError = 'Amount exceeds maximum limit');
    } else {
      setState(() => _customAmountError = null);
    }
  }

  Future<void> _copyUpiId() async {
    await Clipboard.setData(const ClipboardData(text: AppConstants.developerUpiId));
    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(VioraIcons.check, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('UPI ID copied: ${AppConstants.developerUpiId}'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyPaymentLink() async {
    await Clipboard.setData(ClipboardData(text: _currentUpiUri));
    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPI Payment URI copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _launchUpiApp() async {
    if (_selectedPreset == DonationPreset.custom && _customAmountError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_customAmountError!)),
      );
      return;
    }

    final service = ref.read(upiDonationServiceProvider);
    _hasLaunchedPayment = true;

    final result = await service.launchUpi(_currentUpiUri);

    if (!mounted) return;

    if (result == UpiLaunchResult.noUpiAppFound) {
      _hasLaunchedPayment = false;
      _showNoUpiAppDialog();
    } else if (result == UpiLaunchResult.failed) {
      _hasLaunchedPayment = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to launch UPI application. Try copying the UPI ID.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNoUpiAppDialog() {
    final colors = context.colors;
    final typography = context.typography;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Icon(VioraIcons.alert, color: colors.accent, size: 40),
                const SizedBox(height: 12),
                Text('No UPI App Detected', style: typography.headline),
                const SizedBox(height: 8),
                Text(
                  'No supported UPI payment app (such as Google Pay, PhonePe, Paytm, or BHIM) was found on this device.\n\nYou can copy the developer UPI ID below and pay from another device or bank portal.',
                  style: typography.body.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: AppDimensions.borderRadiusCard,
                    border: Border.all(color: colors.separator),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConstants.developerUpiId, style: typography.headline),
                      IconButton(
                        icon: const Icon(VioraIcons.copy, size: 20),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _copyUpiId();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got It'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThankYouSheet() {
    final colors = context.colors;
    final typography = context.typography;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(VioraIcons.heartHandshake, color: colors.accent, size: 36),
                ),
                const SizedBox(height: 16),
                Text('Thank You for Supporting VIORA!', style: typography.headline, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Your encouragement and support help keep independent development alive, offline, and ad-free.\n\nNote: As an offline player with zero telemetry, VIORA does not verify or track banking transactions.',
                  style: typography.body.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: const VioraAppBar(
        title: 'Support VIORA',
        subtitle: 'Optional Developer Support',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // 1. Header Banner & Branding
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Enjoying VIORA?',
              style: typography.largeTitle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'VIORA is built with passion and made to stay free. Your support helps keep independent development alive.',
                style: typography.body.copyWith(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Coffee appreciation card
            VioraCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(VioraIcons.coffee, color: colors.accent, size: 24),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('100% Free & Ad-Free', style: typography.headline),
                        const SizedBox(height: 4),
                        Text(
                          'No tracking, no subscriptions, and no paywalls. Every contribution directly funds future development.',
                          style: typography.footnote.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // 2. Developer UPI ID Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'DIRECT UPI DONATION',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colors.textSecondary,
                ),
              ),
            ),

            VioraCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(VioraIcons.upiPayment, color: colors.accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer UPI ID',
                          style: typography.caption.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          AppConstants.developerUpiId,
                          style: typography.headline.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(VioraIcons.copy, size: 15),
                    label: const Text('Copy'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surfaceSecondary,
                      foregroundColor: colors.accent,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colors.separator),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: _copyUpiId,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // 3. Amount Selection (Uniform width, vertically centered, full width)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'SELECT AMOUNT (OPTIONAL)',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colors.textSecondary,
                ),
              ),
            ),

            Column(
              children: DonationPreset.values.map((preset) {
                final isSelected = _selectedPreset == preset;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onPresetSelected(preset),
                      borderRadius: AppDimensions.borderRadiusCard,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.accent.withValues(alpha: 0.12)
                              : colors.surface,
                          borderRadius: AppDimensions.borderRadiusCard,
                          border: Border.all(
                            color: isSelected ? colors.accent : colors.separator,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.accent.withValues(alpha: 0.20)
                                    : colors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                preset.icon,
                                size: 18,
                                color: isSelected ? colors.accent : colors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    preset.label,
                                    style: typography.body.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? colors.accent : colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    preset.subtitle,
                                    style: typography.footnote.copyWith(
                                      color: isSelected
                                          ? colors.accent.withValues(alpha: 0.85)
                                          : colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? colors.accent : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? colors.accent : colors.textTertiary,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(VioraIcons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedPreset == DonationPreset.custom) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _customAmountController,
                focusNode: _customAmountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Custom Amount (₹)',
                  hintText: 'Enter amount in INR',
                  prefixIcon: const Icon(VioraIcons.rupee, size: 18),
                  errorText: _customAmountError,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    borderSide: BorderSide(color: colors.separator),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    borderSide: BorderSide(color: colors.separator),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                    borderSide: BorderSide(color: colors.accent, width: 1.5),
                  ),
                ),
                onChanged: _validateCustomAmount,
              ),
            ],

            const SizedBox(height: AppDimensions.space16),

            // Pay via UPI Button (prominent, full width, responsive)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(VioraIcons.launch, size: 20),
                label: Text(
                  _currentEffectiveAmount != null
                      ? 'Pay ₹${_currentEffectiveAmount!.toStringAsFixed(0)} via UPI'
                      : 'Pay via UPI App',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusCard,
                  ),
                ),
                onPressed: _launchUpiApp,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // 4. Dynamic UPI QR Code Section (Cohesive with aligned header)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'SCAN TO PAY',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colors.textSecondary,
                ),
              ),
            ),

            VioraCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(VioraIcons.qrCode, color: colors.accent, size: 20),
                    ),
                    title: Text('Scan with UPI App', style: typography.headline),
                    subtitle: Text(
                      _isQrExpanded
                          ? 'GPay, PhonePe, Paytm, BHIM & banking apps'
                          : 'Tap to view live scannable QR',
                      style: typography.footnote,
                    ),
                    trailing: Icon(
                      _isQrExpanded ? VioraIcons.chevronUp : VioraIcons.chevronDown,
                      color: colors.textTertiary,
                    ),
                    onTap: () {
                      setState(() => _isQrExpanded = !_isQrExpanded);
                    },
                  ),
                  if (_isQrExpanded) ...[
                    const Divider(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _currentUpiUri,
                          version: QrVersions.auto,
                          size: 190.0,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentEffectiveAmount != null
                          ? '₹${_currentEffectiveAmount!.toStringAsFixed(0)} • Note: ${AppConstants.upiTransactionNote}'
                          : 'Note: ${AppConstants.upiTransactionNote}',
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(VioraIcons.copy, size: 16),
                          label: const Text('Copy Payment Link'),
                          onPressed: _copyPaymentLink,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // 5. Buy Me a Coffee Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ALTERNATIVE METHODS',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colors.textSecondary,
                ),
              ),
            ),

            VioraCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(VioraIcons.coffee, color: Colors.amber, size: 20),
                ),
                title: Text('Buy Me a Coffee', style: typography.headline),
                subtitle: Text(
                  AppConstants.buyMeACoffeeUrl != null
                      ? 'Support via Buy Me a Coffee external link'
                      : 'Link not yet configured by developer (UPI recommended)',
                  style: typography.footnote,
                ),
                trailing: AppConstants.buyMeACoffeeUrl != null
                    ? const Icon(VioraIcons.externalLink, size: 18)
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.separator),
                        ),
                        child: Text('Pending', style: typography.caption.copyWith(fontSize: 10)),
                      ),
                onTap: () {
                  if (AppConstants.buyMeACoffeeUrl != null) {
                    ref.read(upiDonationServiceProvider).openExternalUrl(AppConstants.buyMeACoffeeUrl!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buy Me a Coffee page is pending developer setup. Please use UPI!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // 6. Privacy & Security Assurance Note
            Row(
              children: [
                Icon(VioraIcons.security, size: 16, color: colors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No financial, banking, or personal credentials are ever collected or stored by VIORA. Donations are processed externally by your installed UPI banking apps.',
                    style: typography.caption.copyWith(color: colors.textTertiary, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }
}
