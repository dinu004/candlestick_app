import 'dart:async';
import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CandleStickController extends GetxController{

  RxList<Candle> candles = <Candle>[].obs;
  RxList<Candle> get initialCandles => RxList(generateHistoricalData());

  late Timer timer;

  Random random = Random();

  StreamController candlesStreamController = StreamController<List<Candle>>.broadcast();
  StreamController priceStreamController = StreamController<double>.broadcast();
  Stream get candlesStream => candlesStreamController.stream;
  Stream get priceStream => priceStreamController.stream;


  void loadData() {
    candles.assignAll(initialCandles);
    priceStream.listen((snapshot) {
      if (snapshot != null) {
        updateCandles(snapshot);
        update();
      }
    });
  }

  List<Candle> generateHistoricalData() {
    List<Candle> historicalCandles = [];
    DateTime currentDate = DateTime.now().subtract(const Duration(minutes: 60));
    double lastClose = generatePrice(); // Initial random close value

    for (int i = 0; i < 120; i++) {
      final double open = lastClose; // Open is the last close
      final double close = generatePrice(); // New random close value
      final double high = max(open, close) + random.nextDouble().roundToDouble() * 5; // Ensure high is greater than open and close
      final double low = min(open, close) - random.nextDouble().roundToDouble() * 5; // Ensure low is less than open and close
      final double volume = random.nextDouble() * 1000;

      historicalCandles.add(Candle(
        date: currentDate.add(Duration(minutes: i)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      lastClose = close;
    }

    return historicalCandles;
  }

  double generatePrice() {
    return (500 + random.nextDouble() * 1000).roundToDouble(); // Generates a random price between 500 and 1000
  }

  void emittingCandles() {
    // Assuming we emit a new candle every minute
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      Candle candle = createCandle();

      candlesStreamController.add([candle]); // Emit new candle data
    });
  }

  Candle createCandle() {
    final DateTime now = DateTime.now();
    final double open = generatePrice();
    final double close = generatePrice();
    final double high = max(open, close) + random.nextDouble() * 5;
    final double low = min(open, close) - random.nextDouble() * 5;
    final double volume = random.nextDouble() * 1000;

    final Candle candle = Candle(
      date: now,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
    return candle;
  }

  Candle createNextCandleByPriceTick(double priceTick) {
    final DateTime now = DateTime.now();
    final double open = priceTick;
    final double close = priceTick;
    final double high = priceTick;
    final double low = priceTick;
    final double volume = random.nextDouble() * 1000;

    final Candle candle = Candle(
      date: now,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
    return candle;
  }

  void emittingPrices() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final double priceTick = generatePrice();
      priceStreamController.add(priceTick);
    });
  }


  void updateCandles(snapshot) {
    if (candles.isNotEmpty) {
      Candle latestCandle = candles.first;
      var priceTick = snapshot.toDouble();
      int timeDifference = DateTime.now().difference(latestCandle.date).inSeconds;
      if (timeDifference >= 60) {
        Candle nextCandle = createNextCandleByPriceTick(priceTick);
        candles.insert(0, nextCandle);
      } else {
        latestCandle = Candle(
            date: latestCandle.date,
            high: max(latestCandle.high, priceTick),
            low: min(latestCandle.low, priceTick),
            open: latestCandle.open,
            close: priceTick,
            volume: latestCandle.volume);
        candles.removeAt(0);
        candles.insert(0, latestCandle);
      }
    }
  }

  @override
  void onInit() {
    candles = initialCandles;
    emittingCandles();
    emittingPrices(); // TODO: implement onInit
    super.onInit();
  }

  @override
  void dispose() {
    timer.cancel();
    candlesStreamController.close();
    priceStreamController.close();
    // TODO: implement dispose
    super.dispose();
  }
}