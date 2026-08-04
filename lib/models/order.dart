class Order {
  final String bookingId;
  final String customerId;
  final String labId;
  final String bookingType;
  final String bookingStatus;
  
  final List<dynamic> bookedItems;
  final List<dynamic> patientDetails;
  final Map<String, dynamic> sampleCollectionAddress;
  
  final List<String>? reportUrls;
  
  final double subTotalAmount;
  final double totalDiscountAmount;
  final double platformFee;
  final double taxAmount;
  final double totalAmountToBePaid;
  final double labPayableAmount;
  
  final String paymentMode;
  final String paymentStatus;
  final String? transactionId;
  final String? transactionHash;
  final String transactionStatus;
  final double paidAmount;
  final DateTime? paidAt;
  
  final String? customerNote;
  final String? labNote;
  final String? cancellationReason;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final String? labName;
  final String? labAddress;
  final String? labPhone;
  final String? labEmail;

  Order({
    required this.bookingId,
    required this.customerId,
    required this.labId,
    required this.bookingType,
    required this.bookingStatus,
    required this.bookedItems,
    required this.patientDetails,
    required this.sampleCollectionAddress,
    this.reportUrls,
    required this.subTotalAmount,
    required this.totalDiscountAmount,
    required this.platformFee,
    required this.taxAmount,
    required this.totalAmountToBePaid,
    required this.labPayableAmount,
    required this.paymentMode,
    required this.paymentStatus,
    this.transactionId,
    this.transactionHash,
    required this.transactionStatus,
    required this.paidAmount,
    this.paidAt,
    this.customerNote,
    this.labNote,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.labName,
    this.labAddress,
    this.labPhone,
    this.labEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      bookingId: json['booking_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      labId: json['lab_id'] ?? '',
      bookingType: json['booking_type'] ?? '',
      bookingStatus: json['booking_status'] ?? '',
      bookedItems: json['booked_tests'] ?? json['booked_items'] ?? [],
      patientDetails: json['patient_details'] ?? (json['patient_name'] != null ? [{'name': json['patient_name']}] : []),
      sampleCollectionAddress: json['sample_collection_address'] ?? {},
      reportUrls: json['report_urls'] != null ? List<String>.from(json['report_urls']) : (json['report_url'] != null ? [json['report_url']] : null),
      subTotalAmount: (json['sub_total_amount'] ?? json['total_price'] ?? 0.0).toDouble(),
      totalDiscountAmount: (json['total_discount_amount'] ?? 0.0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0.0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      totalAmountToBePaid: (json['total_amount_to_be_paid'] ?? json['total_price'] ?? 0.0).toDouble(),
      labPayableAmount: (json['lab_payable_amount'] ?? 0.0).toDouble(),
      paymentMode: json['payment_mode'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      transactionId: json['transaction_id'],
      transactionHash: json['transaction_hash'],
      transactionStatus: json['transaction_status'] ?? '',
      paidAmount: (json['paid_amount'] ?? 0.0).toDouble(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      customerNote: json['customer_note'],
      labNote: json['lab_note'],
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      labName: json['lab_name'],
      labAddress: json['lab_address'],
      labPhone: json['lab_phone'],
      labEmail: json['lab_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'customer_id': customerId,
      'lab_id': labId,
      'booking_type': bookingType,
      'booking_status': bookingStatus,
      'booked_items': bookedItems,
      'patient_details': patientDetails,
      'sample_collection_address': sampleCollectionAddress,
      'report_urls': reportUrls,
      'sub_total_amount': subTotalAmount,
      'total_discount_amount': totalDiscountAmount,
      'platform_fee': platformFee,
      'tax_amount': taxAmount,
      'total_amount_to_be_paid': totalAmountToBePaid,
      'lab_payable_amount': labPayableAmount,
      'payment_mode': paymentMode,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'transaction_hash': transactionHash,
      'transaction_status': transactionStatus,
      'paid_amount': paidAmount,
      'paid_at': paidAt?.toIso8601String(),
      'customer_note': customerNote,
      'lab_note': labNote,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lab_name': labName,
      'lab_address': labAddress,
      'lab_phone': labPhone,
      'lab_email': labEmail,
    };
  }
}

class OrderListResponse {
  final int count;
  final String labId;
  final List<Order> bookings;
  
  OrderListResponse({
    required this.count,
    required this.labId,
    required this.bookings,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      count: json['count'] ?? 0,
      labId: json['lab_id'] ?? '',
      bookings: (json['bookings'] as List<dynamic>?)
          ?.map((e) => Order.fromJson(e))
          .toList() ?? [],
    );
  }
}
