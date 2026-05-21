import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';

class BillGenerator {
  static Future<void> generateAndPrintBill(Order order) async {
    final pdf = pw.Document();

    // Prepare patient info
    String patientName = 'N/A';
    String patientPhone = 'N/A';
    String patientAgeGender = '';
    if (order.patientDetails.isNotEmpty) {
      final p = order.patientDetails.first;
      patientName = p['full_name']?.toString() ?? 'N/A';
      patientPhone = p['phone_number']?.toString() ?? 'N/A';
      patientAgeGender = '${p['age'] ?? 'N/A'} Yrs, ${p['gender'] ?? 'N/A'}';
    }

    // Prepare address
    String addressStr = 'N/A';
    if (order.sampleCollectionAddress.isNotEmpty) {
      final addrParts = [
        order.sampleCollectionAddress['address_1']?.toString(),
        order.sampleCollectionAddress['street_address']?.toString(),
      ].where((s) => s != null && s.isNotEmpty).toList();
      if (addrParts.isNotEmpty) addressStr = addrParts.join(', ');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          order.labName ?? 'Lab Name',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Your Trusted Health Partner',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          order.labAddress ?? '',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Phone: ${order.labPhone ?? ''}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Email: ${order.labEmail ?? ''}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE / BILL',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Date: ${order.createdAt.toLocal().toString().split(' ')[0]}',
                        ),
                        pw.Text('Booking ID: ${order.bookingId}'),
                        pw.Text('Customer ID: ${order.customerId}'),
                        pw.Text('Status: ${order.bookingStatus.toUpperCase()}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 20),

                // Patient & Address Info
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PATIENT DETAILS',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text('Name: $patientName'),
                          pw.Text('Age/Gender: $patientAgeGender'),
                          pw.Text('Phone: $patientPhone'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SAMPLE COLLECTION ADDRESS',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(addressStr),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Booking Type: ${order.bookingType.replaceAll('_', ' ').toUpperCase()}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Table of booked items
                pw.Text(
                  'BOOKED ITEMS',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Item ID', 'Test / Package Name', 'Category'],
                  data: order.bookedItems.map((item) {
                    return [
                      item['item_id']?.toString() ?? '',
                      item['item_name']?.toString() ?? '',
                      item['item_subtitle']?.toString() ?? '',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey800,
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                  },
                ),
                pw.SizedBox(height: 30),

                // Billing Summary
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PAYMENT DETAILS',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text('Mode: ${order.paymentMode.toUpperCase()}'),
                          pw.Text(
                            'Transaction Status: ${order.transactionStatus}',
                          ),
                          if (order.transactionId != null)
                            pw.Text('Transaction ID: ${order.transactionId}'),
                          pw.SizedBox(height: 16),
                          if (order.customerNote != null) ...[
                            pw.Text(
                              'Customer Note:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(order.customerNote!),
                          ],
                          if (order.cancellationReason != null) ...[
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Cancellation Reason:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red800,
                              ),
                            ),
                            pw.Text(
                              order.cancellationReason!,
                              style: const pw.TextStyle(
                                color: PdfColors.red800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Sub Total:'),
                                pw.Text('Rs. ${order.subTotalAmount}'),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Discount:'),
                                pw.Text('- Rs. ${order.totalDiscountAmount}'),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Platform Fee:'),
                                pw.Text('Rs. ${order.platformFee}'),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Tax:'),
                                pw.Text('Rs. ${order.taxAmount}'),
                              ],
                            ),
                            pw.Divider(color: PdfColors.grey400),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Total Paid:',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'Rs. ${order.totalAmountToBePaid}',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Lab Payable:',
                                  style: pw.TextStyle(
                                    color: PdfColors.blueGrey600,
                                    fontSize: 10,
                                  ),
                                ),
                                pw.Text(
                                  'Rs. ${order.labPayableAmount}',
                                  style: pw.TextStyle(
                                    color: PdfColors.blueGrey600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Thank you for trusting ${order.labName ?? 'us'}. This is a computer-generated document and requires no signature.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Use Printing to layout and show print/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bill_${order.bookingId}.pdf',
    );
  }
}
