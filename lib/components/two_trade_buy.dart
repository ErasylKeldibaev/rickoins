import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwoTradeBuy extends StatelessWidget {
  final Function(int) onAmountChanged;
  const TwoTradeBuy({super.key, required this.onAmountChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Text('Offer buy: '),
        SizedBox(width: 100, child: TextField(
          onChanged: (v) => onAmountChanged(int.tryParse(v) ?? 0),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '0', border: InputBorder.none),
        )),
      ]),
    );
  }
}