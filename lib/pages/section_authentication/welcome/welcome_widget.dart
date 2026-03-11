
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = 'welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  static const List<String> _businessMarkets = <String>[
    'Retail',
    'Food & Beverage',
    'Pharmacy',
    'Electronics',
    'Fashion',
    'Automotive',
    'Hospitality',
    'Other',
  ];

  bool _loading = true;
  bool _submitting = false;
  String? _selectedMarket;
  String? _anonymousUid;

  @override
  void initState() {
    super.initState();
    _bootstrapAnonymousSession();
  }

  Future<void> _bootstrapAnonymousSession() async {
    try {
      if (!loggedIn) {
        final signedInUser = await authManager.signInAnonymously(context);
        if (signedInUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Could not start anonymous session.')),
            );
          }
          return;
        }
      }

      final uid = currentUserUid;
      if (uid.isEmpty) {
        return;
      }

      _anonymousUid = uid;
      try {
        await _saveOrUpdateVisitorProfile(uid: uid);
      } on FirebaseException catch (e) {
        debugPrint(
          'visitor_profiles bootstrap save failed: ${e.code} ${e.message}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile save skipped: ${e.code}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveOrUpdateVisitorProfile({required String uid}) async {
    final now = DateTime.now().toUtc();
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _collectDeviceInfo();
    final ipGeo = await _collectIpAndGeo();

    final doc = <String, dynamic>{
      'userId': uid,
      'isAnonymous': FirebaseAuth.instance.currentUser?.isAnonymous ?? true,
      'entryAt': Timestamp.fromDate(now),
      'lastSeenAt': Timestamp.fromDate(now),
      'market': _selectedMarket,
      'app': {
        'name': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      },
      'runtime': {
        'platform': defaultTargetPlatform.name,
        'kIsWeb': kIsWeb,
        'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
        'timeZoneName': now.timeZoneName,
        'timeZoneOffsetMinutes': now.timeZoneOffset.inMinutes,
        'screenWidth': MediaQuery.sizeOf(context).width,
        'screenHeight': MediaQuery.sizeOf(context).height,
        'pixelRatio': MediaQuery.devicePixelRatioOf(context),
      },
      'network': ipGeo,
      'device': deviceInfo,
    };

    await FirebaseFirestore.instance
        .collection('visitor_profiles')
        .doc(uid)
        .set(doc, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> _collectIpAndGeo() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode != 200) {
        return <String, dynamic>{
          'lookupOk': false,
          'statusCode': response.statusCode,
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return <String, dynamic>{
        'lookupOk': true,
        'ip': data['ip'],
        'country': data['country_name'],
        'countryCode': data['country_code'],
        'city': data['city'],
        'region': data['region'],
        'timezone': data['timezone'],
        'postal': data['postal'],
        'org': data['org'],
      };
    } catch (_) {
      return <String, dynamic>{
        'lookupOk': false,
      };
    }
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final plugin = DeviceInfoPlugin();

    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      return <String, dynamic>{
        'browserName': info.browserName.name,
        'userAgent': info.userAgent,
        'platform': info.platform,
        'vendor': info.vendor,
        'language': info.language,
        'hardwareConcurrency': info.hardwareConcurrency,
      };
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await plugin.androidInfo;
        return <String, dynamic>{
          'brand': info.brand,
          'model': info.model,
          'manufacturer': info.manufacturer,
          'device': info.device,
          'hardware': info.hardware,
          'versionRelease': info.version.release,
          'versionSdkInt': info.version.sdkInt,
        };
      case TargetPlatform.iOS:
        final info = await plugin.iosInfo;
        return <String, dynamic>{
          'name': info.name,
          'systemName': info.systemName,
          'systemVersion': info.systemVersion,
          'model': info.model,
          'localizedModel': info.localizedModel,
          'isPhysicalDevice': info.isPhysicalDevice,
        };
      case TargetPlatform.macOS:
        final info = await plugin.macOsInfo;
        return <String, dynamic>{
          'computerName': info.computerName,
          'model': info.model,
          'osRelease': info.osRelease,
          'arch': info.arch,
          'kernelVersion': info.kernelVersion,
        };
      case TargetPlatform.windows:
        final info = await plugin.windowsInfo;
        return <String, dynamic>{
          'computerName': info.computerName,
          'userName': info.userName,
          'numberOfCores': info.numberOfCores,
          'systemMemoryInMegabytes': info.systemMemoryInMegabytes,
          'majorVersion': info.majorVersion,
          'minorVersion': info.minorVersion,
          'buildNumber': info.buildNumber,
          'productName': info.productName,
        };
      case TargetPlatform.linux:
        final info = await plugin.linuxInfo;
        return <String, dynamic>{
          'name': info.name,
          'version': info.version,
          'id': info.id,
          'idLike': info.idLike,
          'versionCodename': info.versionCodename,
          'prettyName': info.prettyName,
          'variant': info.variant,
        };
      case TargetPlatform.fuchsia:
        return <String, dynamic>{'platform': 'fuchsia'};
    }
  }

  Future<void> _continueToApp() async {
    if (_selectedMarket == null || _anonymousUid == null) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      try {
        await _saveOrUpdateVisitorProfile(uid: _anonymousUid!);
      } on FirebaseException catch (e) {
        debugPrint(
          'visitor_profiles continue save failed: ${e.code} ${e.message}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile save skipped: ${e.code}')),
          );
        }
      }
      if (mounted) {
        context.goNamedAuth(ImportDataWidget.routeName, context.mounted);
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF6A1B9A),
                        Color(0xFFAB47BC),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0xFFAD1457),
                        Color(0x00AD1457),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: [
                          BoxShadow(
                            color: theme.alternate,
                            blurRadius: 14.0,
                            offset: const Offset(0.0, 6.0),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 180.0,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hellow viewer',
                                  style: theme.headlineMedium,
                                ),
                                const SizedBox(height: 8.0),
                                if (_anonymousUid != null)
                                  Text(
                                    'anonymous id: $_anonymousUid',
                                    style: theme.bodyMedium,
                                  ),
                                const SizedBox(height: 24.0),
                                Text(
                                  'select youe bussiness market',
                                  style: theme.titleMedium,
                                ),
                                const SizedBox(height: 12.0),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedMarket,
                                  items: _businessMarkets
                                      .map(
                                        (market) => DropdownMenuItem<String>(
                                          value: market,
                                          child: Text(market),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMarket = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Choose market',
                                    filled: true,
                                    fillColor: theme.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: context.mounted
                                        ? () => context.goNamedAuth(
                                              Auth2Widget.routeName,
                                              context.mounted,
                                            )
                                        : null,
                                    child: const Text('Navigate to Auth2'),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        (_selectedMarket == null || _submitting)
                                            ? null
                                            : _continueToApp,
                                    child: _submitting
                                        ? const SizedBox(
                                            height: 20.0,
                                            width: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                            ),
                                          )
                                        : const Text('Navigate to ImportData'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
