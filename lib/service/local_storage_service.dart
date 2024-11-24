import 'dart:developer';

import 'package:localstore/localstore.dart';
import 'package:namer_app/model/fuel_comparator.dart';

class LocalStorageService {
  static const String TOKEN = 'saved_comparison';
  final db = Localstore.instance;

  Future<void> save(FuelComparator obj) async {
    final id = db.collection(TOKEN).doc().id;
    obj.id = id;
    await db.collection(TOKEN).doc(id).set(obj.toJson());
    log('Saved $obj');
    log(db.collection(TOKEN).doc(id).toString());
  }

  Future<List<FuelComparator>> getAll() async {
    final data = await db.collection(TOKEN).get();
    if (data == null) return [];
    return data.entries.map((e) => FuelComparator.fromJson(e.value)).toList();
  }

  Future<void> delete(String id) async {
    await db.collection(TOKEN).doc(id).delete();
  }
}
