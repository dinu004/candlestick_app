import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/candlestick_chart_controller.dart';

class CandleStickView extends StatelessWidget {
  CandleStickView({Key? key}) : super(key: key);

  CandleStickController candleStickController = Get.put(CandleStickController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candlestick Chart'),
      ),
      body: GetBuilder<CandleStickController>(
        initState: (_) {
          candleStickController.loadData();
        }, // Load initial data
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Candlesticks(
              key: const Key("SYM"),
              candles: candleStickController.candles,
            ),
          );
        },
      ),
    );
  }
}
