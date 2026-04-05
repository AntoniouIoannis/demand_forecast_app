import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OnholdUsersRecord extends FirestoreRecord {
  OnholdUsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "isAnonymous" field.
  bool? _isAnonymous;
  bool get isAnonymous => _isAnonymous ?? false;
  bool hasIsAnonymous() => _isAnonymous != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "firstSeenAt" field.
  DateTime? _firstSeenAt;
  DateTime? get firstSeenAt => _firstSeenAt;
  bool hasFirstSeenAt() => _firstSeenAt != null;

  // "lastSeenAt" field.
  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _lastSeenAt;
  bool hasLastSeenAt() => _lastSeenAt != null;

  // "market" field.
  String? _market;
  String get market => _market ?? '';
  bool hasMarket() => _market != null;

  // "marketCountry" field.
  String? _marketCountry;
  String get marketCountry => _marketCountry ?? '';
  bool hasMarketCountry() => _marketCountry != null;

  // "forecastHorizonDays" field.
  int? _forecastHorizonDays;
  int get forecastHorizonDays => _forecastHorizonDays ?? 0;
  bool hasForecastHorizonDays() => _forecastHorizonDays != null;

  // "consentAccepted" field.
  bool? _consentAccepted;
  bool get consentAccepted => _consentAccepted ?? false;
  bool hasConsentAccepted() => _consentAccepted != null;

  // "previousAnonymousUid" field.
  String? _previousAnonymousUid;
  String get previousAnonymousUid => _previousAnonymousUid ?? '';
  bool hasPreviousAnonymousUid() => _previousAnonymousUid != null;

  // "convertedAt" field.
  DateTime? _convertedAt;
  DateTime? get convertedAt => _convertedAt;
  bool hasConvertedAt() => _convertedAt != null;

  // "profileWriteOk" field.
  bool? _profileWriteOk;
  bool get profileWriteOk => _profileWriteOk ?? false;
  bool hasProfileWriteOk() => _profileWriteOk != null;

  // "firstName" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  bool hasFirstName() => _firstName != null;

  // "lastName" field.
  String? _lastName;
  String get lastName => _lastName ?? '';
  bool hasLastName() => _lastName != null;

  // "website" field.
  String? _website;
  String get website => _website ?? '';
  bool hasWebsite() => _website != null;

  // "productCategory" field.
  String? _productCategory;
  String get productCategory => _productCategory ?? '';
  bool hasProductCategory() => _productCategory != null;

  // "seasonalCalendar" field.
  String? _seasonalCalendar;
  String get seasonalCalendar => _seasonalCalendar ?? '';
  bool hasSeasonalCalendar() => _seasonalCalendar != null;

  // "naceCode" field.
  String? _naceCode;
  String get naceCode => _naceCode ?? '';
  bool hasNaceCode() => _naceCode != null;

  // "profileStage" field.
  String? _profileStage;
  String get profileStage => _profileStage ?? '';
  bool hasProfileStage() => _profileStage != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _userId = snapshotData['userId'] as String?;
    _isAnonymous = snapshotData['isAnonymous'] as bool?;
    _status = snapshotData['status'] as String?;
    _firstSeenAt = snapshotData['firstSeenAt'] as DateTime?;
    _lastSeenAt = snapshotData['lastSeenAt'] as DateTime?;
    _market = snapshotData['market'] as String?;
    _marketCountry = snapshotData['marketCountry'] as String?;
    _forecastHorizonDays = castToType<int>(snapshotData['forecastHorizonDays']);
    _consentAccepted = snapshotData['consentAccepted'] as bool?;
    _previousAnonymousUid = snapshotData['previousAnonymousUid'] as String?;
    _convertedAt = snapshotData['convertedAt'] as DateTime?;
    _profileWriteOk = snapshotData['profileWriteOk'] as bool?;
    _firstName = snapshotData['firstName'] as String?;
    _lastName = snapshotData['lastName'] as String?;
    _website = snapshotData['website'] as String?;
    _productCategory = snapshotData['productCategory'] as String?;
    _seasonalCalendar = snapshotData['seasonalCalendar'] as String?;
    _naceCode = snapshotData['naceCode'] as String?;
    _profileStage = snapshotData['profileStage'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('onhold_users');

  static Stream<OnholdUsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OnholdUsersRecord.fromSnapshot(s));

  static Future<OnholdUsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OnholdUsersRecord.fromSnapshot(s));

  static OnholdUsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OnholdUsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OnholdUsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OnholdUsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OnholdUsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OnholdUsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOnholdUsersRecordData({
  String? uid,
  String? userId,
  bool? isAnonymous,
  String? status,
  DateTime? firstSeenAt,
  DateTime? lastSeenAt,
  String? market,
  String? marketCountry,
  int? forecastHorizonDays,
  bool? consentAccepted,
  String? previousAnonymousUid,
  DateTime? convertedAt,
  bool? profileWriteOk,
  String? firstName,
  String? lastName,
  String? website,
  String? productCategory,
  String? seasonalCalendar,
  String? naceCode,
  String? profileStage,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'userId': userId,
      'isAnonymous': isAnonymous,
      'status': status,
      'firstSeenAt': firstSeenAt,
      'lastSeenAt': lastSeenAt,
      'market': market,
      'marketCountry': marketCountry,
      'forecastHorizonDays': forecastHorizonDays,
      'consentAccepted': consentAccepted,
      'previousAnonymousUid': previousAnonymousUid,
      'convertedAt': convertedAt,
      'profileWriteOk': profileWriteOk,
      'firstName': firstName,
      'lastName': lastName,
      'website': website,
      'productCategory': productCategory,
      'seasonalCalendar': seasonalCalendar,
      'naceCode': naceCode,
      'profileStage': profileStage,
    }.withoutNulls,
  );

  return firestoreData;
}

class OnholdUsersRecordDocumentEquality implements Equality<OnholdUsersRecord> {
  const OnholdUsersRecordDocumentEquality();

  @override
  bool equals(OnholdUsersRecord? e1, OnholdUsersRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.userId == e2?.userId &&
        e1?.isAnonymous == e2?.isAnonymous &&
        e1?.status == e2?.status &&
        e1?.firstSeenAt == e2?.firstSeenAt &&
        e1?.lastSeenAt == e2?.lastSeenAt &&
        e1?.market == e2?.market &&
        e1?.marketCountry == e2?.marketCountry &&
        e1?.forecastHorizonDays == e2?.forecastHorizonDays &&
        e1?.consentAccepted == e2?.consentAccepted &&
        e1?.previousAnonymousUid == e2?.previousAnonymousUid &&
        e1?.convertedAt == e2?.convertedAt &&
        e1?.profileWriteOk == e2?.profileWriteOk &&
        e1?.firstName == e2?.firstName &&
        e1?.lastName == e2?.lastName &&
        e1?.website == e2?.website &&
        e1?.productCategory == e2?.productCategory &&
        e1?.seasonalCalendar == e2?.seasonalCalendar &&
        e1?.naceCode == e2?.naceCode &&
        e1?.profileStage == e2?.profileStage;
  }

  @override
  int hash(OnholdUsersRecord? e) => const ListEquality().hash([
        e?.uid,
        e?.userId,
        e?.isAnonymous,
        e?.status,
        e?.firstSeenAt,
        e?.lastSeenAt,
        e?.market,
        e?.marketCountry,
        e?.forecastHorizonDays,
        e?.consentAccepted,
        e?.previousAnonymousUid,
        e?.convertedAt,
        e?.profileWriteOk,
        e?.firstName,
        e?.lastName,
        e?.website,
        e?.productCategory,
        e?.seasonalCalendar,
        e?.naceCode,
        e?.profileStage,
      ]);

  @override
  bool isValidKey(Object? o) => o is OnholdUsersRecord;
}
