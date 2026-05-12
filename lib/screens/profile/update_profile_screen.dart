import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/user.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _labNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _panController;
  late TextEditingController _nablController;
  late TextEditingController _gstController;
  late TextEditingController _emergencyController;
  late TextEditingController _whatsappController;

  String? _labLogoPath;
  String? _regCertPath;
  String? _bankPassbookPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _labNameController = TextEditingController(text: user?.labName);
    _mobileController = TextEditingController(text: user?.mobileNumber);
    _emailController = TextEditingController(text: user?.email);
    _addressController = TextEditingController(text: user?.address);
    _panController = TextEditingController(text: user?.panNumber);
    _nablController = TextEditingController(text: user?.nablNumber);
    _gstController = TextEditingController(text: user?.gstNumber);
    _emergencyController = TextEditingController(text: user?.emergencyContact);
    _whatsappController = TextEditingController(text: user?.whatsappNumber);

    _labLogoPath = user?.labLogo;
    _regCertPath = user?.registrationCertificate;
    _bankPassbookPath = user?.bankPassbook;
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _nablController.dispose();
    _gstController.dispose();
    _emergencyController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _labLogoPath = image.path;
        } else {
          _regCertPath = image.path;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _bankPassbookPath = result.files.single.path!;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).user;
      final updatedUser = User(
        id: user?.id,
        labName: _labNameController.text,
        mobileNumber: _mobileController.text,
        email: _emailController.text,
        address: _addressController.text,
        panNumber: _panController.text,
        nablNumber: _nablController.text,
        gstNumber: _gstController.text,
        emergencyContact: _emergencyController.text,
        whatsappNumber: _whatsappController.text,
        labLogo: _labLogoPath,
        registrationCertificate: _regCertPath,
        bankPassbook: _bankPassbookPath,
      );

      // Only pass paths that are NOT URLs (meaning they are local files)
      final String? labLogoFile =
          (_labLogoPath != null && !_labLogoPath!.startsWith('http'))
          ? _labLogoPath
          : null;
      final String? regCertFile =
          (_regCertPath != null && !_regCertPath!.startsWith('http'))
          ? _regCertPath
          : null;
      final String? bankPassbookFile =
          (_bankPassbookPath != null && !_bankPassbookPath!.startsWith('http'))
          ? _bankPassbookPath
          : null;

      await ref
          .read(profileProvider.notifier)
          .updateProfile(
            updatedUser,
            labLogoFile: labLogoFile,
            regCertFile: regCertFile,
            bankPassbookFile: bankPassbookFile,
          );

      if (mounted) {
        final profileState = ref.read(profileProvider);
        if (profileState.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(profileState.error!)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Update Profile',
        subtitle: 'EDIT LABORATORY DETAILS',
        showDrawer: false,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('BASIC INFORMATION'),
              _buildTextField(
                _labNameController,
                'Lab Name',
                IconsaxPlusLinear.hospital,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _mobileController,
                'Mobile Number',
                IconsaxPlusLinear.call,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'Email Address',
                IconsaxPlusLinear.sms,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('LOCATION & COMPLIANCE'),
              _buildTextField(
                _addressController,
                'Full Address',
                IconsaxPlusLinear.location,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _panController,
                'PAN Number',
                IconsaxPlusLinear.card_pos,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _nablController,
                'NABL Number',
                IconsaxPlusLinear.verify,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _gstController,
                'GST Number (Optional)',
                IconsaxPlusLinear.receipt_text,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('CONNECTIVITY'),
              _buildTextField(
                _emergencyController,
                'Emergency Contact',
                IconsaxPlusLinear.call_calling,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _whatsappController,
                'WhatsApp Number',
                IconsaxPlusLinear.messages_1,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('DOCUMENTS'),
              _buildFilePicker(
                'Laboratory Logo',
                _labLogoPath,
                () => _pickImage(true),
              ),
              const SizedBox(height: 16),
              _buildFilePicker(
                'Registration Certificate',
                _regCertPath,
                () => _pickImage(false),
              ),
              const SizedBox(height: 16),
              _buildFilePicker('Bank Passbook', _bankPassbookPath, _pickFile),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileState.isLoading ? null : _handleUpdate,
                  child: profileState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: AppTextStyles.tagline.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryAccent, size: 22),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) && !hint.contains('Optional')
          ? 'Required'
          : null,
    );
  }

  Widget _buildFilePicker(String label, String? filePath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filePath != null
                ? AppColors.primaryAccent
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              filePath != null
                  ? IconsaxPlusBold.document_text
                  : IconsaxPlusLinear.document_upload,
              color: filePath != null
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary,
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
                    filePath != null
                        ? filePath.split('/').last.split('?').first
                        : 'Click to update',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (filePath != null)
              const Icon(
                IconsaxPlusBold.tick_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
