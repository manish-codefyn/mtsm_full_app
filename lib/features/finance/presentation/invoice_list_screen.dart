import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../data/finance_repository.dart';
import '../data/models/invoice.dart';
import 'package:intl/intl.dart';

// Provider for Invoices
final studentInvoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.watch(financeRepositoryProvider).getStudentInvoices();
});

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  late Razorpay _razorpay;
  String? _pendingInvoiceId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingInvoiceId == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment successful! Verifying...")),
    );

    final success = await ref.read(financeRepositoryProvider).verifyPayment(
      _pendingInvoiceId!, 
      response.paymentId!, 
      response.orderId!, 
      response.signature!
    );

    if (success) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification Successful. Invoice Updated.")),
      );
      ref.refresh(studentInvoicesProvider); // Refresh list
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Verification Failed. Please contact support.")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  Future<void> _startPayment(Invoice invoice) async {
    try {
      _pendingInvoiceId = invoice.id;
      final orderData = await ref.read(financeRepositoryProvider).initiatePayment(invoice.id);
      
      var options = {
        'key': orderData['key_id'],
        'amount': orderData['amount'] * 100, // in paise
        'name': 'School ERP',
        'description': 'Invoice #${invoice.invoiceNumber}',
        'order_id': orderData['order_id'],
        'prefill': {
          'contact': '', // Can fetch from user profile
          'email': ''    // Can fetch from user profile
        }
      };

      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initiate payment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(studentInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invoices'),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Inv #${invoice.invoiceNumber}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildStatusChip(invoice.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Due: ${DateFormat.yMMMd().format(invoice.dueDate)}"),
                      Text("Tax: \$${invoice.totalTax.toStringAsFixed(2)}"), // Showing Tax
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${invoice.dueAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          if (!invoice.isPaid)
                            ElevatedButton.icon(
                              onPressed: () => _startPayment(invoice),
                              icon: const Icon(Icons.payment, size: 18),
                              label: const Text("Pay Now"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () {
                                // Download logic here or open URL
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Downloading Invoice with GST Info...")),
                                );
                              },
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text("Invoice"),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PAID':
        color = Colors.green;
        break;
      case 'overdue':
      case 'OVERDUE':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
