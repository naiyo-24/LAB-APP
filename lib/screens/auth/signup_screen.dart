import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../notifiers/auth_notifier.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  // Controllers
  final _labNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _panController = TextEditingController();
  final _nablController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Files
  File? _labLogo;
  File? _regCert;
  File? _bankPassbook;

  // Checkboxes
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _labLogo = File(image.path);
        } else {
          _regCert = File(image.path);
        }
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _bankPassbook = File(result.files.single.path!);
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _handleSignup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  Future<void> _handleSignup() async {
    if (!_termsAccepted || !_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and privacy policy')),
      );
      return;
    }

    final data = {
      'lab_name': _labNameController.text,
      'mobile_number': _mobileController.text,
      'email_address': _emailController.text,
      'password': _passwordController.text,
      'pan_number': _panController.text,
      'nabl_accreditation_number': _nablController.text,
      'address': _addressController.text,
      'gst_number': _gstController.text,
      'emergency_contact_number': _emergencyController.text,
      'whatsapp_number': _whatsappController.text,
      'terms_conditions_accepted': _termsAccepted,
      'privacy_policy_accepted': _privacyAccepted,
    };

    final filePaths = [
      if (_labLogo != null) _labLogo!.path,
      if (_regCert != null) _regCert!.path,
      if (_bankPassbook != null) _bankPassbook!.path,
    ];

    await ref
        .read(authProvider.notifier)
        .signup(data: data, filePaths: filePaths);

    final authState = ref.read(authProvider);
    if (authState.user != null) {
      context.go('/login'); // Or dashboard
    } else if (authState.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildSlide(
                    title: 'Lab Identity',
                    subtitle: 'TELL US ABOUT YOUR LABORATORY',
                    children: [
                      _buildTextField(
                        _labNameController,
                        'Laboratory Name',
                        IconsaxPlusLinear.hospital,
                      ),
                      _buildTextField(
                        _mobileController,
                        'Mobile Number',
                        IconsaxPlusLinear.call,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Account Security',
                    subtitle: 'SET UP YOUR LOGIN CREDENTIALS',
                    children: [
                      _buildTextField(
                        _emailController,
                        'Email Address',
                        IconsaxPlusLinear.sms,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        _passwordController,
                        'Password',
                        IconsaxPlusLinear.lock,
                        isPassword: true,
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Compliance',
                    subtitle: 'TAX AND ACCREDITATION DETAILS',
                    children: [
                      _buildTextField(
                        _panController,
                        'PAN Number',
                        IconsaxPlusLinear.card_pos,
                      ),
                      _buildTextField(
                        _nablController,
                        'NABL Number',
                        IconsaxPlusLinear.verify,
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Business Info',
                    subtitle: 'LOCATION AND TAX REGISTRATION',
                    children: [
                      _buildTextField(
                        _addressController,
                        'Full Address',
                        IconsaxPlusLinear.location,
                      ),
                      _buildTextField(
                        _gstController,
                        'GST Number (Optional)',
                        IconsaxPlusLinear.receipt_text,
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Connectivity',
                    subtitle: 'EMERGENCY AND WHATSAPP CONTACTS',
                    children: [
                      _buildTextField(
                        _emergencyController,
                        'Emergency Contact',
                        IconsaxPlusLinear.call_calling,
                      ),
                      _buildTextField(
                        _whatsappController,
                        'WhatsApp Number',
                        IconsaxPlusLinear.messages_1,
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Visuals & Proof',
                    subtitle: 'UPLOAD LOGO AND REGISTRATION CERTIFICATE',
                    children: [
                      _buildFilePicker(
                        'Laboratory Logo',
                        _labLogo,
                        () => _pickImage(true),
                      ),
                      _buildFilePicker(
                        'Registration Certificate',
                        _regCert,
                        () => _pickImage(false),
                      ),
                    ],
                  ),
                  _buildSlide(
                    title: 'Financials',
                    subtitle: 'UPLOAD BANK PASSBOOK OR CANCELLED CHEQUE',
                    children: [
                      _buildFilePicker(
                        'Bank Passbook',
                        _bankPassbook,
                        _pickFile,
                      ),
                    ],
                  ),
                  _buildAgreementsSlide(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final authState = ref.watch(authProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(title, style: AppTextStyles.header),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.tagline),
          const SizedBox(height: 32),
          ...children.expand((w) => [w, const SizedBox(height: 20)]),
          const SizedBox(height: 12),
          _buildNavigationSection(authState),
        ],
      ),
    );
  }

  Widget _buildAgreementsSlide() {
    final authState = ref.watch(authProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Final Steps', style: AppTextStyles.header),
          const SizedBox(height: 8),
          const Text(
            'ACCEPT TERMS AND PRIVACY POLICY',
            style: AppTextStyles.tagline,
          ),
          const SizedBox(height: 32),
          _buildCheckboxTile(
            'Terms & Conditions',
            'I agree to the Medy24 service terms and conditions for lab partners.',
            _termsAccepted,
            (v) => setState(() => _termsAccepted = v!),
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            'Privacy Policy',
            'I have read and understood how my data will be managed by Medy24.',
            _privacyAccepted,
            (v) => setState(() => _privacyAccepted = v!),
          ),
          const SizedBox(height: 32),
          _buildNavigationSection(authState),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(AuthState authState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _nextPage,
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _currentPage == _totalPages - 1
                        ? 'Complete Registration'
                        : 'Next Step',
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (_currentPage == 0)
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.description.copyWith(fontSize: 14),
                children: [
                  const TextSpan(text: "Already have an account? "),
                  TextSpan(
                    text: 'Login',
                    style: const TextStyle(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go('/login'),
                  ),
                ],
              ),
            ),
          )
        else
          Center(
            child: TextButton(
              onPressed: _previousPage,
              child: const Text(
                'Go Back',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryAccent, size: 22),
      ),
    );
  }

  Widget _buildFilePicker(String label, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: file != null ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Row(
          children: [
            Icon(
              file != null
                  ? IconsaxPlusLinear.document_text_1
                  : IconsaxPlusLinear.document_upload,
              color: file != null ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                  Text(
                    file != null
                        ? file.path.split('/').last
                        : 'Click to upload document',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (file != null)
              const Icon(
                IconsaxPlusLinear.tick_circle,
                color: AppColors.success,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildCheckboxTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
    );
  }
}
