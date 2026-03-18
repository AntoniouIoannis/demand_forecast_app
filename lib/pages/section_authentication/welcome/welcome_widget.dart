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
  static const String _profileCollection = 'onhold_users';
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
  static const List<String> _marketCountries = <String>[
    'Greece',
    'Cyprus',
    'Italy',
    'Germany',
    'France',
    'Spain',
    'United Kingdom',
    'United States',
  ];
  static const List<int> _forecastHorizons = <int>[30, 90, 365];

  bool _loading = true;
  bool _submitting = false;
  String? _selectedMarket;
  String? _selectedCountry;
  int? _selectedForecastHorizonDays;
  String? _anonymousUid;
  bool _privacyConsentAccepted = false;
  bool _profileWriteOk = false;
  String _profileWriteStatus = 'not-started';
  DateTime? _lastProfileWriteAt;
  Map<String, dynamic>? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _bootstrapAnonymousSession();
  }

  Future<User?> _restorePersistedAuthUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      return current;
    }

    try {
      return await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
    } catch (_) {
      return FirebaseAuth.instance.currentUser;
    }
  }

  Future<void> _bootstrapAnonymousSession() async {
    try {
      final restoredUser = await _restorePersistedAuthUser();

      if (restoredUser == null && !loggedIn) {
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

      final uid = FirebaseAuth.instance.currentUser?.uid ?? currentUserUid;
      if (uid.isEmpty) {
        return;
      }

      _anonymousUid = uid;
      try {
        await _saveOrUpdateVisitorProfile(uid: uid);
      } on FirebaseException catch (e) {
        debugPrint(
          '$_profileCollection bootstrap save failed: ${e.code} ${e.message}',
        );
        if (mounted) {
          setState(() {
            _profileWriteOk = false;
            _profileWriteStatus = 'error:${e.code}';
            _lastProfileWriteAt = DateTime.now().toUtc();
          });
        }
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
    if (mounted) {
      setState(() {
        _deviceInfo = deviceInfo;
      });
    }
    final ipGeo = await _collectIpAndGeo();
    final docRef =
        FirebaseFirestore.instance.collection(_profileCollection).doc(uid);
    final existingSnapshot = await docRef.get();
    final existingData = existingSnapshot.data() ?? const <String, dynamic>{};

    final firstSeenAt = existingData['firstSeenAt'] ??
        existingData['entryAt'] ??
        Timestamp.fromDate(now);
    final isAnonymous = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    final consentAccepted =
        _privacyConsentAccepted || existingData['consentAccepted'] == true;

    final doc = <String, dynamic>{
      'uid': uid,
      'userId': uid,
      'isAnonymous': isAnonymous,
      'status': isAnonymous ? 'anonymous' : 'authenticated',
      'firstSeenAt': firstSeenAt,
      'entryAt': firstSeenAt,
      'lastSeenAt': Timestamp.fromDate(now),
      'market': _selectedMarket,
      'marketCountry': _selectedCountry,
      'forecastHorizonDays': _selectedForecastHorizonDays,
      'consentAccepted': consentAccepted,
      'profileWriteOk': true,
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

    await docRef.set(doc, SetOptions(merge: true));
    final verifiedSnapshot = await docRef.get();
    if (mounted) {
      setState(() {
        _profileWriteOk = verifiedSnapshot.exists;
        _profileWriteStatus =
            verifiedSnapshot.exists ? 'saved' : 'not-found-after-write';
        _lastProfileWriteAt = DateTime.now().toUtc();
      });
    }
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
    if (_selectedMarket == null ||
        _selectedCountry == null ||
        _selectedForecastHorizonDays == null ||
        _anonymousUid == null) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      FFAppState().update(() {
        FFAppState().selectedBusinessMarket = _selectedMarket;
        FFAppState().selectedMarketCountry = _selectedCountry;
        FFAppState().forecastHorizonDays = _selectedForecastHorizonDays;
      });

      try {
        await _saveOrUpdateVisitorProfile(uid: _anonymousUid!);
      } on FirebaseException catch (e) {
        debugPrint(
          '$_profileCollection continue save failed: ${e.code} ${e.message}',
        );
        if (mounted) {
          setState(() {
            _profileWriteOk = false;
            _profileWriteStatus = 'error:${e.code}';
            _lastProfileWriteAt = DateTime.now().toUtc();
          });
        }
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

  Future<void> _showPrivacyMessageThenContinue() async {
    if (_submitting) {
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy Message'),
        content: const Text(
          'You are log in already as an anonymous user, to give you some privelege.\n'
          'First, Peek a selection above,\nis little bussiness info to improve your accuracy services and quality.\n'
          'Your uploaded data is used only for generating forecast models.\n'
          'Files are not shared with third parties and can be deleted at any time,\n'
          'data needed to improve forecast accuracy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (accepted == true && mounted) {
      _privacyConsentAccepted = true;
      await _continueToApp();
    }
  }

  Widget _buildAdminDebugPanel() {
    final theme = FlutterFlowTheme.of(context);
    final activeUser = FirebaseAuth.instance.currentUser;
    final activeUid = activeUser?.uid ?? '-';
    final isAnonymous = activeUser?.isAnonymous ?? false;
    final lastWrite = _lastProfileWriteAt != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_lastProfileWriteAt!)
        : '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Debug', style: theme.titleSmall),
          const SizedBox(height: 8.0),
          Text('active uid: $activeUid', style: theme.bodySmall),
          Text('is anonymous: $isAnonymous', style: theme.bodySmall),
          Text(
            'profile path: $_profileCollection/${_anonymousUid ?? activeUid}',
            style: theme.bodySmall,
          ),
          Text('profile write status: $_profileWriteStatus',
              style: theme.bodySmall),
          Text('profile exists after write: $_profileWriteOk',
              style: theme.bodySmall),
          Text('last profile write: $lastWrite', style: theme.bodySmall),
          Text('privacy consent accepted: $_privacyConsentAccepted',
              style: theme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoPanel() {
    final info = _deviceInfo;
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Info',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8.0),
          if (info == null)
            const Text(
              'collecting...',
              style: TextStyle(fontSize: 11.0, color: Colors.grey),
            )
          else
            ...info.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(fontSize: 11.0, color: Colors.black87),
                ),
              ),
            ),
        ],
      ),
    );
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
                                  'Hello, Viewer!',
                                  style: theme.headlineMedium,
                                ),
                                const SizedBox(height: 8.0),
                                if (_anonymousUid != null)
                                  Text(
                                    'anonymous id: $_anonymousUid',
                                    style: theme.bodyMedium,
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildAdminDebugPanel()),
                                    const SizedBox(width: 12.0),
                                    Expanded(child: _buildDeviceInfoPanel()),
                                  ],
                                ),
                                const SizedBox(height: 24.0),
                                Text(
                                  'Select your business market',
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
                                Text(
                                  'Where does your market operate?',
                                  style: theme.titleMedium,
                                ),
                                const SizedBox(height: 12.0),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCountry,
                                  items: _marketCountries
                                      .map(
                                        (country) => DropdownMenuItem<String>(
                                          value: country,
                                          child: Text(country),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCountry = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Choose country market',
                                    filled: true,
                                    fillColor: theme.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Forecast horizon',
                                  style: theme.titleMedium,
                                ),
                                const SizedBox(height: 12.0),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedForecastHorizonDays,
                                  items: _forecastHorizons
                                      .map(
                                        (days) => DropdownMenuItem<int>(
                                          value: days,
                                          child: Text('$days days'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedForecastHorizonDays = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select horizon',
                                    filled: true,
                                    fillColor: theme.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 56.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onPressed: context.mounted
                                              ? () => context.goNamedAuth(
                                                    Auth2Widget.routeName,
                                                    context.mounted,
                                                  )
                                              : null,
                                          child: const Text('Sign Up'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: SizedBox(
                                        height: 56.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onPressed: (_selectedMarket == null ||
                                                  _selectedCountry == null ||
                                                  _selectedForecastHorizonDays ==
                                                      null ||
                                                  _submitting)
                                              ? null
                                              : _showPrivacyMessageThenContinue,
                                          child: _submitting
                                              ? const SizedBox(
                                                  height: 20.0,
                                                  width: 20.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                  ),
                                                )
                                              : const Text('Go to ImportData'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.0,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A1B9A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: context.mounted
                                        ? () => context.pushNamed(
                                              HomePageWidget.routeName,
                                            )
                                        : null,
                                    icon: const Icon(Icons.dashboard_rounded,
                                        size: 20.0),
                                    label: const Text(
                                      'Dashboard',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
