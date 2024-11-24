import 'dart:ffi';
import 'dart:math';

import 'package:namer_app/utils/fuel_enum.dart';

class FuelComparator {
  String id;
  double price1;
  double price2;
  double consumption1;
  double consumption2;
  Fuel fuel1;
  Fuel fuel2;
  double price_result1;
  double price_result2;

  FuelComparator(
      this.id,
      this.price1,
      this.price2,
      this.consumption1,
      this.consumption2,
      this.fuel1,
      this.fuel2,
      this.price_result1,
      this.price_result2);

  toJson() {
    return {
      'id': id,
      'price1': price1,
      'price2': price2,
      'consumption1': consumption1,
      'consumption2': consumption2,
      'fuel1': fuel1.label,
      'fuel2': fuel2.label,
      'price_result1': price_result1,
      'price_result2': price_result2
    };
  }

  static FuelComparator fromJson(Map<String, dynamic> json) {
    for (var key in json.keys) {
      print('key: $key, value: ${json[key]}');
    }
    return FuelComparator(
        json['id'],
        json['price1'],
        json['price2'],
        json['consumption1'],
        json['consumption2'],
        Fuel.values.firstWhere((element) => element.label == json['fuel1']),
        Fuel.values.firstWhere((element) => element.label == json['fuel2']),
        json['price_result1'],
        json['price_result2']);
  }

  @override
  toString() {
    return 'FuelComparator{id: $id, price1: $price1, price2: $price2, consumption1: $consumption1, consumption2: $consumption2, fuel1: $fuel1, fuel2: $fuel2, price_result1: $price_result1, price_result2: $price_result2}';
  }
}
