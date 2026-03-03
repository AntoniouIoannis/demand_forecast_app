import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DemoRecord extends FirestoreRecord {
  DemoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "product_id" field.
  String? _productId;
  String get productId => _productId ?? '';
  bool hasProductId() => _productId != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "integer" field.
  double? _integer;
  double get integer => _integer ?? 0.0;
  bool hasInteger() => _integer != null;

  void _initializeFields() {
    _productId = snapshotData['product_id'] as String?;
    _description = snapshotData['description'] as String?;
    _date = snapshotData['date'] as DateTime?;
    _price = castToType<double>(snapshotData['price']);
    _integer = castToType<double>(snapshotData['integer']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('demo');

  static Stream<DemoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DemoRecord.fromSnapshot(s));

  static Future<DemoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DemoRecord.fromSnapshot(s));

  static DemoRecord fromSnapshot(DocumentSnapshot snapshot) => DemoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DemoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DemoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DemoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DemoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDemoRecordData({
  String? productId,
  String? description,
  DateTime? date,
  double? price,
  double? integer,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'product_id': productId,
      'description': description,
      'date': date,
      'price': price,
      'integer': integer,
    }.withoutNulls,
  );

  return firestoreData;
}

class DemoRecordDocumentEquality implements Equality<DemoRecord> {
  const DemoRecordDocumentEquality();

  @override
  bool equals(DemoRecord? e1, DemoRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.description == e2?.description &&
        e1?.date == e2?.date &&
        e1?.price == e2?.price &&
        e1?.integer == e2?.integer;
  }

  @override
  int hash(DemoRecord? e) => const ListEquality()
      .hash([e?.productId, e?.description, e?.date, e?.price, e?.integer]);

  @override
  bool isValidKey(Object? o) => o is DemoRecord;
}
