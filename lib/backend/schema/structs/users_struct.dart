// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class UsersStruct extends FFFirebaseStruct {
  UsersStruct({
    int? userId,
    String? email,
    String? password,
    String? repeatPsw,
    String? uid,
    String? displayName,
    String? photoUrl,
    DateTime? createdTime,
    String? phoneNumber,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _userId = userId,
        _email = email,
        _password = password,
        _repeatPsw = repeatPsw,
        _uid = uid,
        _displayName = displayName,
        _photoUrl = photoUrl,
        _createdTime = createdTime,
        _phoneNumber = phoneNumber,
        super(firestoreUtilData);

  // "user_id" field.
  int? _userId;
  int get userId => _userId ?? 0;
  set userId(int? val) => _userId = val;

  void incrementUserId(int amount) => userId = userId + amount;

  bool hasUserId() => _userId != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  set password(String? val) => _password = val;

  bool hasPassword() => _password != null;

  // "repeat_psw" field.
  String? _repeatPsw;
  String get repeatPsw => _repeatPsw ?? '';
  set repeatPsw(String? val) => _repeatPsw = val;

  bool hasRepeatPsw() => _repeatPsw != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  set uid(String? val) => _uid = val;

  bool hasUid() => _uid != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  set photoUrl(String? val) => _photoUrl = val;

  bool hasPhotoUrl() => _photoUrl != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  set createdTime(DateTime? val) => _createdTime = val;

  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  set phoneNumber(String? val) => _phoneNumber = val;

  bool hasPhoneNumber() => _phoneNumber != null;

  static UsersStruct fromMap(Map<String, dynamic> data) => UsersStruct(
        userId: castToType<int>(data['user_id']),
        email: data['email'] as String?,
        password: data['password'] as String?,
        repeatPsw: data['repeat_psw'] as String?,
        uid: data['uid'] as String?,
        displayName: data['display_name'] as String?,
        photoUrl: data['photo_url'] as String?,
        createdTime: data['created_time'] as DateTime?,
        phoneNumber: data['phone_number'] as String?,
      );

  static UsersStruct? maybeFromMap(dynamic data) =>
      data is Map ? UsersStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'user_id': _userId,
        'email': _email,
        'password': _password,
        'repeat_psw': _repeatPsw,
        'uid': _uid,
        'display_name': _displayName,
        'photo_url': _photoUrl,
        'created_time': _createdTime,
        'phone_number': _phoneNumber,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'user_id': serializeParam(
          _userId,
          ParamType.int,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'password': serializeParam(
          _password,
          ParamType.String,
        ),
        'repeat_psw': serializeParam(
          _repeatPsw,
          ParamType.String,
        ),
        'uid': serializeParam(
          _uid,
          ParamType.String,
        ),
        'display_name': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'photo_url': serializeParam(
          _photoUrl,
          ParamType.String,
        ),
        'created_time': serializeParam(
          _createdTime,
          ParamType.DateTime,
        ),
        'phone_number': serializeParam(
          _phoneNumber,
          ParamType.String,
        ),
      }.withoutNulls;

  static UsersStruct fromSerializableMap(Map<String, dynamic> data) =>
      UsersStruct(
        userId: deserializeParam(
          data['user_id'],
          ParamType.int,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        password: deserializeParam(
          data['password'],
          ParamType.String,
          false,
        ),
        repeatPsw: deserializeParam(
          data['repeat_psw'],
          ParamType.String,
          false,
        ),
        uid: deserializeParam(
          data['uid'],
          ParamType.String,
          false,
        ),
        displayName: deserializeParam(
          data['display_name'],
          ParamType.String,
          false,
        ),
        photoUrl: deserializeParam(
          data['photo_url'],
          ParamType.String,
          false,
        ),
        createdTime: deserializeParam(
          data['created_time'],
          ParamType.DateTime,
          false,
        ),
        phoneNumber: deserializeParam(
          data['phone_number'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UsersStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsersStruct &&
        userId == other.userId &&
        email == other.email &&
        password == other.password &&
        repeatPsw == other.repeatPsw &&
        uid == other.uid &&
        displayName == other.displayName &&
        photoUrl == other.photoUrl &&
        createdTime == other.createdTime &&
        phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode => const ListEquality().hash([
        userId,
        email,
        password,
        repeatPsw,
        uid,
        displayName,
        photoUrl,
        createdTime,
        phoneNumber
      ]);
}

UsersStruct createUsersStruct({
  int? userId,
  String? email,
  String? password,
  String? repeatPsw,
  String? uid,
  String? displayName,
  String? photoUrl,
  DateTime? createdTime,
  String? phoneNumber,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UsersStruct(
      userId: userId,
      email: email,
      password: password,
      repeatPsw: repeatPsw,
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      createdTime: createdTime,
      phoneNumber: phoneNumber,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UsersStruct? updateUsersStruct(
  UsersStruct? users, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    users
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUsersStructData(
  Map<String, dynamic> firestoreData,
  UsersStruct? users,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (users == null) {
    return;
  }
  if (users.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && users.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final usersData = getUsersFirestoreData(users, forFieldValue);
  final nestedData = usersData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = users.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUsersFirestoreData(
  UsersStruct? users, [
  bool forFieldValue = false,
]) {
  if (users == null) {
    return {};
  }
  final firestoreData = mapToFirestore(users.toMap());

  // Add any Firestore field values
  users.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUsersListFirestoreData(
  List<UsersStruct>? userss,
) =>
    userss?.map((e) => getUsersFirestoreData(e, true)).toList() ?? [];
