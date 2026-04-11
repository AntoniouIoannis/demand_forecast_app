import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "repassword" field.
  String? _repassword;
  String get repassword => _repassword ?? '';
  bool hasRepassword() => _repassword != null;

  // "mobilephone" field.
  String? _mobilephone;
  String get mobilephone => _mobilephone ?? '';
  bool hasMobilephone() => _mobilephone != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

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

  // "marketCountry" field.
  String? _marketCountry;
  String get marketCountry => _marketCountry ?? '';
  bool hasMarketCountry() => _marketCountry != null;

  // "forecastHorizonDays" field.
  int? _forecastHorizonDays;
  int get forecastHorizonDays => _forecastHorizonDays ?? 0;
  bool hasForecastHorizonDays() => _forecastHorizonDays != null;

  // "seasonalCalendar" field.
  String? _seasonalCalendar;
  String get seasonalCalendar => _seasonalCalendar ?? '';
  bool hasSeasonalCalendar() => _seasonalCalendar != null;

  // "naceCode" field.
  String? _naceCode;
  String get naceCode => _naceCode ?? '';
  bool hasNaceCode() => _naceCode != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _password = snapshotData['password'] as String?;
    _repassword = snapshotData['repassword'] as String?;
    _mobilephone = snapshotData['mobilephone'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _firstName = snapshotData['firstName'] as String?;
    _lastName = snapshotData['lastName'] as String?;
    _website = snapshotData['website'] as String?;
    _productCategory = snapshotData['productCategory'] as String?;
    _marketCountry = snapshotData['marketCountry'] as String?;
    _forecastHorizonDays = castToType<int>(snapshotData['forecastHorizonDays']);
    _seasonalCalendar = snapshotData['seasonalCalendar'] as String?;
    _naceCode = snapshotData['naceCode'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? password,
  String? repassword,
  String? mobilephone,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? firstName,
  String? lastName,
  String? website,
  String? productCategory,
  String? marketCountry,
  int? forecastHorizonDays,
  String? seasonalCalendar,
  String? naceCode,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'password': password,
      'repassword': repassword,
      'mobilephone': mobilephone,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'website': website,
      'productCategory': productCategory,
      'marketCountry': marketCountry,
      'forecastHorizonDays': forecastHorizonDays,
      'seasonalCalendar': seasonalCalendar,
      'naceCode': naceCode,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.password == e2?.password &&
        e1?.repassword == e2?.repassword &&
        e1?.mobilephone == e2?.mobilephone &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.firstName == e2?.firstName &&
        e1?.lastName == e2?.lastName &&
        e1?.website == e2?.website &&
        e1?.productCategory == e2?.productCategory &&
        e1?.marketCountry == e2?.marketCountry &&
        e1?.forecastHorizonDays == e2?.forecastHorizonDays &&
        e1?.seasonalCalendar == e2?.seasonalCalendar &&
        e1?.naceCode == e2?.naceCode;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.password,
        e?.repassword,
        e?.mobilephone,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.firstName,
        e?.lastName,
        e?.website,
        e?.productCategory,
        e?.marketCountry,
        e?.forecastHorizonDays,
        e?.seasonalCalendar,
        e?.naceCode
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
