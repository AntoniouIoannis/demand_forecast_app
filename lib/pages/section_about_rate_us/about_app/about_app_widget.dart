import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_app_model.dart';
export 'about_app_model.dart';

class AboutAppWidget extends StatefulWidget {
  const AboutAppWidget({super.key});

  static String routeName = 'AboutApp';
  static String routePath = 'aboutApp';

  @override
  State<AboutAppWidget> createState() => _AboutAppWidgetState();
}

class _AboutAppWidgetState extends State<AboutAppWidget>
    with TickerProviderStateMixin {
  late AboutAppModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AboutAppModel());

    final initialIndex = FFAppState().aboutAppInitialTab.clamp(0, 3);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FFAppState().update(() {
        FFAppState().aboutAppInitialTab = 0;
      });
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  Widget _buildTabSection({required String title, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFD9E2F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: FlutterFlowTheme.of(context).primary, size: 22.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  title,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            body,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard({
    required String imagePath,
    required String name,
    required String role,
    required String about,
    required String linkedInUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFD9E2F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 66.0,
                height: 66.0,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      role,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                          color: FlutterFlowTheme.of(context).secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            about,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 10.0),
          InkWell(
            onTap: () => launchURL(linkedInUrl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18.0,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 6.0),
                Text(
                  'Open LinkedIn Profile',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineHighlight({
    required String eyebrow,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF13294B), Color(0xFF1E4D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 14.0,
            offset: Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w700,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  color: const Color(0xFFBFD6FF),
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 10.0),
          Text(
            body,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  color: const Color(0xFFE8F1FF),
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSection({
    required IconData icon,
    required String title,
    required String body,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFD9E2F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: accentColor, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          RichText(
            text: TextSpan(
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: body),
              ],
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'About App',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: theme.headlineMedium.fontWeight,
                fontStyle: theme.headlineMedium.fontStyle,
              ),
              color: Colors.white,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 2.0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFD5E2FF),
            labelStyle: theme.bodyMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
            tabs: const [
              Tab(text: 'About App'),
              Tab(text: 'Team'),
              Tab(text: 'Security App'),
              Tab(text: 'Engine Prediction'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabSection(
                  title: 'A practical AI platform you can trust',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        icon: Icons.track_changes_rounded,
                        title: 'Built for real daily decisions',
                        body:
                            'This app helps teams move from spreadsheet guesswork to reliable, data-driven actions. Users can upload data, run forecasting quickly, and get outputs they can understand and use immediately.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildInfoCard(
                        icon: Icons.handshake_rounded,
                        title: 'Designed for confidence and adoption',
                        body:
                            'The interface is clear, guided, and friendly for non-technical users. Every step of the flow is focused on speed, clarity, and business value, so people can trust the result and act with confidence.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildInfoCard(
                        icon: Icons.insights_rounded,
                        title: 'From insight to impact',
                        body:
                            'Beyond predictions, the app supports business planning by turning data into practical insights. It gives companies the power to reduce uncertainty and improve stock, sales, and operational decisions.',
                      ),
                    ],
                  ),
                ),
                _buildTabSection(
                  title: 'People behind the product',
                  child: Column(
                    children: [
                      _buildTeamCard(
                        imagePath: 'assets/images/profil_demo.jpg',
                        name: 'Giannis Antoniou',
                        role: 'Co-Founder and AI Product Engineer',
                        about:
                            'I build practical AI products that transform business data into clear actions. My focus is trust, performance, and fast user value in every release.',
                        linkedInUrl:
                            'https://www.linkedin.com/in/%CE%B9%CF%89%CE%AC%CE%BD%CE%BD%CE%B7%CF%82-%CE%B1%CE%BD%CF%84%CF%89%CE%BD%CE%AF%CE%BF%CF%85-giannis-antoniou-046b684b/',
                      ),
                      const SizedBox(height: 10.0),
                      _buildTeamCard(
                        imagePath: 'assets/images/somon.jpg',
                        name: 'Georgios Kiminos',
                        role: 'Co-Founder and Business Strategy Lead',
                        about:
                            'I connect product direction with real market needs. I focus on sustainable growth, customer value, and turning innovation into measurable business outcomes.',
                        linkedInUrl:
                            'https://www.linkedin.com/in/georgios-kiminos-04111973/?originalSubdomain=gr',
                      ),
                    ],
                  ),
                ),
                _buildTabSection(
                  title: 'Security and BaaS reliability',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        icon: Icons.shield_rounded,
                        title: 'Secure-by-default architecture',
                        body:
                            'Our platform uses a Backend-as-a-Service stack with authenticated access, secured data paths, and strict separation of user data. Security rules help ensure each user only accesses permitted resources.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildInfoCard(
                        icon: Icons.storage_rounded,
                        title: 'Managed infrastructure and resilience',
                        body:
                            'BaaS services provide managed uptime, scalable storage, and built-in monitoring. This reduces operational risk and allows fast, dependable delivery without sacrificing security controls.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildInfoCard(
                        icon: Icons.verified_user_rounded,
                        title: 'Identity, access, and governance',
                        body:
                            'Authentication and role-aware access keep sensitive actions controlled. The app is designed to support auditable workflows and safe collaboration for teams handling business-critical data.',
                      ),
                    ],
                  ),
                ),
                _buildTabSection(
                  title: 'Prediction engine built for business execution',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEngineHighlight(
                        eyebrow: 'THE ENGINE OF THE APPLICATION',
                        title:
                            'The Python ML Linear Regression Model at the heart of the platform',
                        body:
                            'At the heart of my full-stack SaaS application is a V12 engine: a Python ML Linear Regression model. It is the engine that embodies three key characteristics: absolute predictive power, adaptation to the needs of each market and the reliability required of a hyperSaaS.',
                      ),
                      const SizedBox(height: 12.0),
                      _buildEngineSection(
                        icon: Icons.flash_on_rounded,
                        title: 'Power',
                        accentColor: const Color(0xFFD84315),
                        body:
                            'Each token that is activated releases a service agreement that pushes the application to 9,500 rpm, giving an acceleration in performance that will have you on the edge of your seat, proving that power in our platform is synonymous with absolute control over predictions.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildEngineSection(
                        icon: Icons.tune_rounded,
                        title: 'Adaptation',
                        accentColor: const Color(0xFF00897B),
                        body:
                            'The magic, however, lies in the adaptation. Our model does not simply give numbers. Instead, it dynamically adapts to seasonal calendars, business markets and country sales. Whether you are analyzing seasonal trends or comparing different markets, the algorithm response is immediate and personalized. This ability to adapt turns a complex ML model into a precision tool in the hands of the user.',
                      ),
                      const SizedBox(height: 10.0),
                      _buildEngineSection(
                        icon: Icons.verified_rounded,
                        title: 'Reliability',
                        accentColor: const Color(0xFF3949AB),
                        body:
                            'Every pipeline, from data processing to final forecast, is designed to withstand the limits. With the power of Firebase and GCP as a foundation, the reliability of the application is guaranteed even under extreme load conditions, offering the user the luxury of peace of mind: you know that when you run a forecast, the answer will always be the same, unwavering and accurate.',
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: const Color(0xFFD9E2F0)),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                            children: const [
                              TextSpan(
                                text: 'In short: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    'the engine of my application is not just a set of algorithms. It is the perfect balance between the raw predictive power that fascinates, the intelligent adaptation that makes each analysis unique, and the impeccable reliability that accompanies you in every business decision.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
