import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String partnerUid;
  final int passedAmount;
  final String partnerNickname;
  final String pageLable;

  const PaymentPage({
    super.key,
    required this.partnerUid,
    required this.passedAmount,
    required this.partnerNickname,
    required this.pageLable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment to $partnerNickname')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Amount: $passedAmount Rc\$',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Partner: $partnerNickname'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
