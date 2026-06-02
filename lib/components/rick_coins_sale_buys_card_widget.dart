import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/local_user_provider.dart';

class RickCoinsSaleBuyCardWidget extends StatelessWidget {
  const RickCoinsSaleBuyCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(children: [
        const Text('My offer sale:'),
        SizedBox(width: 60, child: TextField(
          onChanged: (v) => userProvider.updateSaleIntent(int.tryParse(v) ?? 0),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '0', border: InputBorder.none, contentPadding: EdgeInsets.only(left: 8)),
        )),
        const SizedBox(width: 10),
        const Text('I will buy:'),
        SizedBox(width: 60, child: TextField(
          onChanged: (v) => userProvider.updateBuyIntent(int.tryParse(v) ?? 0),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '0', border: InputBorder.none, contentPadding: EdgeInsets.only(left: 8)),
        )),
      ]),
    );
  }
}