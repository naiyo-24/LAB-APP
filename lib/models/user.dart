class User {
  final String? id;
  final String? labName;
  final String? mobileNumber;
  final String? email;
  final String? panNumber;
  final String? nablNumber;
  final String? address;
  final String? gstNumber;
  final String? emergencyContact;
  final String? whatsappNumber;
  final String? labLogo;
  final String? registrationCertificate;
  final String? bankPassbook;

  User({
    this.id,
    this.labName,
    this.mobileNumber,
    this.email,
    this.panNumber,
    this.nablNumber,
    this.address,
    this.gstNumber,
    this.emergencyContact,
    this.whatsappNumber,
    this.labLogo,
    this.registrationCertificate,
    this.bankPassbook,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['lab_id'] ?? json['id'],
      labName: json['lab_name'],
      mobileNumber: json['mobile_number'],
      email: json['email_address'] ?? json['email'],
      panNumber: json['pan_number'],
      nablNumber: json['nabl_accreditation_number'],
      address: json['address'],
      gstNumber: json['gst_number'],
      emergencyContact: json['emergency_contact_number'],
      whatsappNumber: json['whatsapp_number'],
      labLogo: json['lab_logo_url'] ?? json['lab_logo'],
      registrationCertificate: json['registration_certificate_url'] ?? json['registration_certificate'],
      bankPassbook: json['bank_passbook_url'] ?? json['bank_passbook'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lab_id': id,
      'lab_name': labName,
      'mobile_number': mobileNumber,
      'email_address': email,
      'pan_number': panNumber,
      'nabl_accreditation_number': nablNumber,
      'address': address,
      'gst_number': gstNumber,
      'emergency_contact_number': emergencyContact,
      'whatsapp_number': whatsappNumber,
      'lab_logo_url': labLogo,
      'registration_certificate_url': registrationCertificate,
      'bank_passbook_url': bankPassbook,
    };
  }
}
