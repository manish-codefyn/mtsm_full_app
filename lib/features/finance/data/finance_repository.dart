import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/fee_structure.dart';
import 'models/invoice.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref));

class FinanceRepository {
  final Ref _ref;

  FinanceRepository(this._ref);

  Future<List<FeeStructure>> getFeeStructures() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('finance/fee-structures/');
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => FeeStructure.fromJson(json)).toList();
  }

  Future<List<Invoice>> getStudentInvoices() async {
    final dio = _ref.read(apiClientProvider).client;
    // Note: URL matches what we set in Django router: api/v1/finance/student/invoices/
    final response = await dio.get('finance/student/invoices/'); 
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => Invoice.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> initiatePayment(String invoiceId) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.post('finance/student/invoices/$invoiceId/initiate-payment/');
    return response.data;
  }

  Future<bool> verifyPayment(String invoiceId, String paymentId, String orderId, String signature) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.post('finance/student/invoices/$invoiceId/verify-payment/', data: {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
