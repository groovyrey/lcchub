import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'theme/app_theme.dart';
import 'models/models.dart';
import 'api/portal_api.dart';
import 'services/session_storage.dart';
import 'services/notification_service.dart';
import 'services/version_check_service.dart';
import 'services/offline_service.dart';
import 'services/push_service.dart';
import 'screens/login/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/grades/grades_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/community/post_detail_screen.dart';
import 'screens/community/create_post_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/assistant/assistant_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/notification_drawer.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.init();
  PushService.init();
  runApp(const PortalApp());
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final brightness = state.themeMode == ThemeMode.system
              ? WidgetsBinding.instance.platformDispatcher.platformBrightness
              : state.themeMode == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light;
          AppColors.setThemeBrightness(brightness);

          return MaterialApp(
            title: 'LCC Hub',
            theme: buildAppTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashWrapper(),
          );
        },
      ),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AppState>().finishSplash();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.showSplash) {
      return const AppShell();
    }
    return const AnimatedSplash();
  }
}

class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _loaderController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loaderController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)));
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.6)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _loaderController, curve: Curves.easeIn));

    _logoController.forward().then((_) {
      _textController.forward();
      _loaderController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleOpacity.value,
                    child: Transform.translate(
                      offset: _titleSlide.value,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'LCC Hub',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _loaderController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loaderOpacity.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8)),
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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const _screens = ['dashboard', 'grades', 'accounts', 'community', 'assistant', 'settings', 'about'];
  static const _labels = ['Home', 'Grades', 'Accounts', 'Community', 'Assistant', 'Settings', 'About'];
  static final _icons = [
    PhosphorIcons.house(), PhosphorIcons.exam(), PhosphorIcons.receipt(),
    PhosphorIcons.chats(PhosphorIconsStyle.fill), PhosphorIcons.robot(PhosphorIconsStyle.fill), PhosphorIcons.gearSix(), PhosphorIcons.info(),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _updateShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShowUpdate();
  }

  void _maybeShowUpdate() {
    if (_updateShown) return;
    final update = context.read<AppState>().pendingUpdate;
    if (update == null) return;
    _updateShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showUpdateDialog(update));
  }

  void _showUpdateDialog(VersionInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(PhosphorIcons.download(), color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Update Available', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${info.latestVersion} is available.', style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 4),
            Text('You are on v${info.currentVersion}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant)),
            if (info.changelog.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('What\'s New:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(info.changelog, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurfaceVariant), maxLines: 6, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AppState>().dismissUpdate();
              Navigator.pop(ctx);
            },
            child: Text('Later', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () async {
              final uri = Uri.parse(info.downloadUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (ctx.mounted) {
                context.read<AppState>().dismissUpdate();
                Navigator.pop(ctx);
              }
            },
            child: Text('Download', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    _maybeShowUpdate();

    if (!state.isLoggedIn) {
      return LoginScreen(
        isLoading: state.isLoading,
        error: state.error,
        onLogin: (u, p) => state.login(u, p),
        onClearError: () => state.clearError(),
      );
    }

    return AppScaffold(state: state, screens: AppShell._screens, labels: AppShell._labels, icons: AppShell._icons);
  }
}

class AppScaffold extends StatefulWidget {
  final AppState state;
  final List<String> screens;
  final List<String> labels;
  final List<IconData> icons;

  const AppScaffold({
    super.key,
    required this.state,
    required this.screens,
    required this.labels,
    required this.icons,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.labels[_currentIndex], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.list()),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          _buildNotifBell(),
        ],
      ),
      drawer: _buildDrawer(context),
      endDrawer: const NotificationDrawer(),
      body: Column(
        children: [
          if (state.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: AppColors.warning.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Icon(PhosphorIcons.warningCircle(), size: 14, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text('No connection — showing cached data',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildNotifBell() {
    final state = context.watch<AppState>();
    final count = state.unreadCount;
    return IconButton(
      icon: Badge(
        isLabelVisible: count > 0,
        label: count > 99 ? const Text('99+') : null,
        child: Icon(PhosphorIcons.bell()),
      ),
      onPressed: () {
        state.loadNotifications();
        _scaffoldKey.currentState?.openEndDrawer();
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final state = widget.state;
    return Drawer(
      width: 280,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: state.student?.id ?? ''),
                ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('LCC Hub', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(state.student?.name ?? '', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                  Text('ID: ${state.student?.id ?? ''}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                  const SizedBox(height: 4),
                  Text('View Profile \u2192', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.screens.length,
              itemBuilder: (context, index) {
                final selected = _currentIndex == index;
                return ListTile(
                  leading: Icon(widget.icons[index], color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
                  title: Text(widget.labels[index], style: GoogleFonts.poppins(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.onSurface,
                  )),
                  selected: selected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () {
                    setState(() => _currentIndex = index);
                    Navigator.pop(context);
                    if (widget.screens[index] == 'community') {
                      state.startCommunityPolling();
                    } else {
                      state.stopCommunityPolling();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final state = widget.state;
    return switch (widget.screens[_currentIndex]) {
      'dashboard' => DashboardScreen(student: state.student, onRefresh: () => state.refreshStudent()),
      'grades' => GradesScreen(
        reports: state.student?.availableReports ?? [],
        loadedGrades: state.loadedGrades,
        loadingSemesterHref: state.loadingSemesterHref,
        onSemesterClick: (r) => state.loadGrades(r),
      ),
      'accounts' => AccountsScreen(financials: state.student?.financials, onRefresh: () => state.refreshStudent()),
      'community' => CommunityScreen(
        posts: state.communityPosts,
        hasMore: state.hasMorePosts,
        isLoading: state.isCommunityLoading,
        selectedTopic: state.selectedTopic,
        searchQuery: state.searchQuery,
        currentUserId: state.student?.id,
        onTopicSelected: (t) => state.setTopic(t),
        onSearchChanged: (q) => state.setSearch(q),
        onSortChanged: (s) => state.setSort(s),
        onLikePost: (id) => state.likePost(id),
        onPostClick: (id) => _openPost(context, id),
        onVotePoll: (postId, idx) => state.votePoll(postId, idx),
        onDeletePost: (id) => state.deletePost(id),
        onReportPost: (id) => state.reportPost(id),
        onAuthorTap: (userId) => _openProfile(context, userId),
        onCreatePost: () => _createPost(context),
        onLoadMore: () => state.loadMorePosts(),
        onRefresh: () => state.refreshCommunity(),
      ),
      'assistant' => AssistantScreen(
        messages: state.chatMessages,
        isGenerating: state.isGenerating,
        error: state.chatError,
        onSendMessage: (m) => state.sendMessage(m),
        onStop: () => state.stopGeneration(),
        onClearChat: () => state.clearChat(),
      ),
      'settings' => SettingsScreen(
        student: state.student,
        notificationsEnabled: state.remindersEnabled,
        onNotificationToggle: (v) => state.toggleReminders(v),
        themeMode: state.themeMode,
        onThemeModeChanged: (mode) => state.setThemeMode(mode),
        onLogout: () => state.logout(),
      ),
      'about' => const AboutScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  void _openPost(BuildContext context, String postId) {
    context.read<AppState>().loadPostDetail(postId);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Consumer<AppState>(
        builder: (context, state, _) => PostDetailScreen(
          post: state.postDetail,
          comments: state.postComments,
          isLoading: state.isPostLoading,
          currentUserId: state.student?.id,
          onAddComment: (c) => state.addComment(postId, c),
          onVotePoll: (postId, idx) => state.votePoll(postId, idx),
          onLikePost: (id) => state.likePost(id),
          onDeletePost: (id) => state.deletePost(id),
          onReportPost: (id) => state.reportPost(id),
          onDeleteComment: (postId, commentId) => state.deleteComment(postId, commentId),
          onReportComment: (postId, commentId) => state.reportComment(postId, commentId),
          onAuthorTap: (userId) => _openProfile(context, userId),
        ),
      ),
    ));
  }

  void _openProfile(BuildContext context, String userId) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProfileScreen(userId: userId),
    ));
  }

  void _createPost(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Consumer<AppState>(
        builder: (context, state, _) => CreatePostScreen(
          onSubmit: (content, topic, anon, poll) {
            state.createPost(content, topic: topic, isAnonymous: anon, poll: poll);
          },
        ),
      ),
    ));
  }
}

class AppState extends ChangeNotifier {
  final _storage = SessionStorage();
  bool _showSplash = true;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  Student? _student;
  bool _remindersEnabled = true;

  List<ReportLink> _reports = [];
  Map<String, List<SubjectGrade>> _loadedGrades = {};
  String? _loadingSemesterHref;

  List<CommunityPost> _communityPosts = [];
  bool _hasMorePosts = false;
  bool _isCommunityLoading = false;
  String? _selectedTopic;
  String _searchQuery = '';
  String _sortOrder = 'recent';
  int _communityOffset = 0;

  bool _isOffline = false;
  DateTime? _lastDataUpdate;
  final _offlineService = OfflineService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  CommunityPost? _postDetail;
  List<CommunityComment> _postComments = [];
  bool _isPostLoading = false;

  List<ChatMessage> _chatMessages = [];
  bool _isGenerating = false;
  String? _chatError;
  StreamSubscription<String>? _chatSubscription;
  Timer? _communityPollTimer;
  Timer? _dataRefreshTimer;
  Timer? _notifPollTimer;

  List<AppNotification> _notifications = [];
  bool _isNotifLoading = false;
  VersionInfo? _pendingUpdate;
  ThemeMode _themeMode = ThemeMode.system;

  bool get showSplash => _showSplash;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  Student? get student => _student;
  bool get remindersEnabled => _remindersEnabled;
  ThemeMode get themeMode => _themeMode;
  List<ReportLink> get reports => _reports;
  Map<String, List<SubjectGrade>> get loadedGrades => _loadedGrades;
  String? get loadingSemesterHref => _loadingSemesterHref;
  List<CommunityPost> get communityPosts => _communityPosts;
  bool get hasMorePosts => _hasMorePosts;
  bool get isCommunityLoading => _isCommunityLoading;
  String? get selectedTopic => _selectedTopic;
  String get searchQuery => _searchQuery;
  CommunityPost? get postDetail => _postDetail;
  List<CommunityComment> get postComments => _postComments;
  bool get isPostLoading => _isPostLoading;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isGenerating => _isGenerating;
  String? get chatError => _chatError;
  List<AppNotification> get notifications => _notifications;
  bool get isNotifLoading => _isNotifLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  VersionInfo? get pendingUpdate => _pendingUpdate;

  bool get isOffline => _isOffline;
  DateTime? get lastDataUpdate => _lastDataUpdate;

  Future<void> init() async {
    await _storage.init();
    await _offlineService.init();
    _isLoggedIn = _storage.isLoggedIn;
    _student = _storage.studentData;
    _remindersEnabled = _storage.remindersEnabled;
    _themeMode = _parseThemeMode(_storage.themeMode);
    PortalApi.init(_storage.baseUrl, _storage);
    _initConnectivity();
    if (_student != null) {
      _reports = _student?.availableReports ?? [];
    }
    notifyListeners();
    if (_isLoggedIn) {
      NotificationService.requestPermission().then((_) => _scheduleRemindersIfNeeded());
      _refreshInBackground();
      _startDataRefreshTimer();
      startNotifPolling();
      _loadCommunity();
      _registerDevice();
    }
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();
    _dataRefreshTimer = Timer.periodic(const Duration(minutes: 2), (_) => _refreshInBackground());
  }

  Future<void> _refreshInBackground() async {
    if (!_isLoggedIn) return;
    try {
      final student = await PortalApi.getMe();
      if (student != null) {
        _student = student;
        _reports = student.availableReports ?? [];
        _storage.studentData = student;
        notifyListeners();
      }
    } catch (_) {}
  }

  void finishSplash() {
    _showSplash = false;
    notifyListeners();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final info = await VersionCheckService.checkForUpdate();
    if (info != null) {
      _pendingUpdate = info;
      notifyListeners();
    }
  }

  void dismissUpdate() {
    _pendingUpdate = null;
  }

  Future<void> login(String userId, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await PortalApi.login(userId, password);
    if (result['success'] == true) {
      _isLoggedIn = true;
      _student = result['data'] as Student;
      _reports = _student?.availableReports ?? [];
      _storage.isLoggedIn = true;
      _storage.studentId = userId;
      _storage.studentData = _student;
      NotificationService.requestPermission().then((_) => _scheduleRemindersIfNeeded());
      _loadCommunity();
      _startDataRefreshTimer();
      startNotifPolling();
      _registerDevice();
    } else {
      _error = result['error']?.toString() ?? 'Login failed';
    }
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _student = null;
    _reports = [];
    _loadedGrades = {};
    _communityPosts = [];
    _chatMessages = [];
    _notifications = [];
    _communityPollTimer?.cancel();
    _communityPollTimer = null;
    _notifPollTimer?.cancel();
    _notifPollTimer = null;
    _storage.clear();
    PortalApi.clearSession();
    NotificationService.cancelAll();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshStudent() async {
    final student = await PortalApi.getMe();
    if (student != null) {
      _student = student;
      _reports = student.availableReports ?? [];
      _storage.studentData = student;
      notifyListeners();
    }
  }

  void refreshCommunity() => _loadCommunity(refresh: true);

  void loadMorePosts() => _loadCommunity();

  void startCommunityPolling() {
    _communityPollTimer?.cancel();
    if (_communityPosts.isEmpty) {
      _loadCommunity(refresh: true);
    }
    _communityPollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _pollCommunity());
  }

  void stopCommunityPolling() {
    _communityPollTimer?.cancel();
    _communityPollTimer = null;
  }

  Future<void> _pollCommunity() async {
    if (!_isLoggedIn || _isCommunityLoading) return;
    try {
      final response = await PortalApi.getCommunityPosts(
        topic: _selectedTopic,
        search: _searchQuery,
        sort: _sortOrder,
        offset: 0,
      );
      final incoming = response.posts;
      if (incoming.isEmpty) return;

      final merged = <CommunityPost>[];

      for (final incomingPost in incoming) {
        final existingIdx = _communityPosts.indexWhere((p) => p.id == incomingPost.id);
        if (existingIdx >= 0) {
          merged.add(incomingPost);
        } else {
          merged.add(incomingPost);
        }
      }

      for (final oldPost in _communityPosts) {
        if (!merged.any((p) => p.id == oldPost.id)) {
          merged.add(oldPost);
        }
      }

      _communityPosts = merged;
      _hasMorePosts = response.hasMore;
      notifyListeners();
    } catch (_) {}
  }

  void setTopic(String? topic) {
    _selectedTopic = topic == 'All' ? null : topic;
    _loadCommunity(refresh: true);
  }

  Timer? _searchDebounce;
  void setSearch(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () => _loadCommunity(refresh: true));
    notifyListeners();
  }

  void setSort(String sort) {
    _sortOrder = sort;
    _loadCommunity(refresh: true);
  }

  Future<void> loadPostDetail(String postId) async {
    _postDetail = null;
    _postComments = [];
    _isPostLoading = true;
    notifyListeners();
    final result = await PortalApi.getPostDetail(postId);
    if (result['success'] == true) {
      _postDetail = result['post'] as CommunityPost?;
      final commentsResult = await PortalApi.getPostComments(postId);
      _postComments = (commentsResult['comments'] as List<CommunityComment>?) ?? [];
    }
    _isPostLoading = false;
    notifyListeners();
  }

  Future<void> addComment(String postId, String content) async {
    final userId = student?.id ?? '';
    final userName = student?.name ?? 'You';
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    _postComments = [..._postComments, CommunityComment(
      id: tempId,
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    )];
    notifyListeners();

    final result = await PortalApi.addComment(postId, content);
    if (result['success'] == true) {
      final realId = result['id']?.toString() ?? tempId;
      _postComments = _postComments.map((c) =>
        c.id == tempId ? CommunityComment(id: realId, postId: postId, userId: userId, userName: userName, content: content, createdAt: c.createdAt) : c
      ).toList();
    } else {
      _postComments = _postComments.where((c) => c.id != tempId).toList();
    }
    notifyListeners();
  }

  Future<void> createPost(String content, {String? topic, bool isAnonymous = false, Map<String, dynamic>? poll}) async {
    await PortalApi.createPost(content, topic: topic, isAnonymous: isAnonymous, poll: poll);
    _loadCommunity(refresh: true);
  }

  Future<void> likePost(String postId) async {
    final userId = student?.id;
    if (userId == null) return;
    final postIdx = _communityPosts.indexWhere((p) => p.id == postId);
    if (postIdx < 0) return;

    final post = _communityPosts[postIdx];
    final isLiked = post.likes?.contains(userId) == true;

    final updatedLikes = List<String>.from(post.likes ?? []);
    if (isLiked) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }

    _communityPosts[postIdx] = CommunityPost(
      id: post.id,
      userId: post.userId,
      userName: post.userName,
      content: post.content,
      topic: post.topic,
      imageUrl: post.imageUrl,
      isAnonymous: post.isAnonymous,
      createdAt: post.createdAt,
      likes: updatedLikes,
      commentCount: post.commentCount,
      poll: post.poll,
    );

    if (_postDetail?.id == postId) {
      _postDetail = _communityPosts[postIdx];
    }
    notifyListeners();

    if (isLiked) {
      await PortalApi.unlikePost(postId);
    } else {
      await PortalApi.likePost(postId);
    }
  }

  Future<void> votePoll(String postId, int optionIndex) async {
    final userId = student?.id;
    if (userId == null) return;

    void applyVote(List<CommunityPost> list) {
      final idx = list.indexWhere((p) => p.id == postId);
      if (idx < 0) return;
      final post = list[idx];
      if (post.poll == null) return;
      final options = post.poll!.options.map((o) => PollOption(
        id: o.id, text: o.text,
        votes: List<String>.from(o.votes),
      )).toList();
      options[optionIndex].votes.add(userId);
      list[idx] = CommunityPost(
        id: post.id, userId: post.userId, userName: post.userName,
        content: post.content, topic: post.topic, imageUrl: post.imageUrl,
        isAnonymous: post.isAnonymous, createdAt: post.createdAt,
        likes: post.likes, commentCount: post.commentCount,
        poll: Poll(question: post.poll!.question, options: options),
      );
    }

    applyVote(_communityPosts);
    if (_postDetail?.id == postId) applyVote([_postDetail!]);
    notifyListeners();

    final success = await PortalApi.votePoll(postId, optionIndex);
    if (!success) {
      _loadCommunity(refresh: true);
      if (_postDetail?.id == postId) loadPostDetail(postId);
    }
  }

  Future<bool> deletePost(String postId) async {
    final success = await PortalApi.deletePost(postId);
    if (success) {
      _communityPosts.removeWhere((p) => p.id == postId);
      if (_postDetail?.id == postId) {
        _postDetail = null;
        _postComments = [];
      }
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    final success = await PortalApi.deleteComment(commentId);
    if (success) {
      _postComments.removeWhere((c) => c.id == commentId);
      notifyListeners();
    }
    return success;
  }

  Future<String?> reportPost(String postId) async {
    final result = await PortalApi.reportPost(postId);
    if (result['success'] == true && result['decision'] == 'REJECTED') {
      _communityPosts.removeWhere((p) => p.id == postId);
      if (_postDetail?.id == postId) {
        _postDetail = null;
        _postComments = [];
      }
      notifyListeners();
      return result['reason'] as String?;
    }
    return null;
  }

  Future<String?> reportComment(String postId, String commentId) async {
    final result = await PortalApi.reportComment(commentId);
    if (result['success'] == true && result['decision'] == 'REJECTED') {
      _postComments.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return result['reason'] as String?;
    }
    return null;
  }

  void sendMessage(String content) {
    _chatMessages = [..._chatMessages, ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), role: 'user', content: content)];
    _isGenerating = true;
    _chatError = null;
    notifyListeners();

    final assistantMsg = ChatMessage(
      id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: '',
      status: 'Thinking...',
    );
    _chatMessages = [..._chatMessages, assistantMsg];
    notifyListeners();

    final messages = _chatMessages.where((m) => m.role == 'user' || (m.role == 'assistant' && m.content.isNotEmpty)).map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    final buffer = StringBuffer();
    _chatSubscription = PortalApi.chatStream(messages).listen(
      (chunk) {
        if (chunk.startsWith('STATUS:')) {
          final status = chunk.substring(7);
          _chatMessages = _chatMessages.map((m) =>
            m.id == assistantMsg.id ? m.copyWith(status: status) : m
          ).toList();
        } else if (chunk.startsWith('TOOL_USED:')) {
          // ignore tool used for now
        } else {
          buffer.write(chunk);
          _chatMessages = _chatMessages.map((m) =>
            m.id == assistantMsg.id ? m.copyWith(content: buffer.toString()) : m
          ).toList();
        }
        notifyListeners();
      },
      onDone: () {
        _isGenerating = false;
        notifyListeners();
      },
      onError: (e) {
        _isGenerating = false;
        _chatError = e.toString();
        notifyListeners();
      },
    );
  }

  void stopGeneration() {
    _chatSubscription?.cancel();
    _isGenerating = false;
    notifyListeners();
  }

  void clearChat() {
    _chatMessages = [];
    _chatError = null;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _isNotifLoading = true;
    notifyListeners();
    _notifications = await PortalApi.getNotifications();
    _isNotifLoading = false;
    notifyListeners();
  }

  void startNotifPolling() {
    _notifPollTimer?.cancel();
    _notifPollTimer = Timer.periodic(const Duration(minutes: 5), (_) => _pollNotifications());
    _loadNotificationsIfNeeded();
  }

  void stopNotifPolling() {
    _notifPollTimer?.cancel();
    _notifPollTimer = null;
  }

  void _loadNotificationsIfNeeded() {
    if (_notifications.isEmpty && _isLoggedIn) {
      loadNotifications();
    }
  }

  Future<void> _pollNotifications() async {
    if (!_isLoggedIn) return;
    final notifs = await PortalApi.getNotifications();
    if (notifs.isNotEmpty) {
      _notifications = notifs;
      notifyListeners();
    }
  }

  Future<void> markNotifRead(String id) async {
    await PortalApi.markNotificationRead(id);
    _notifications = _notifications.map((n) =>
      n.id == id ? AppNotification(id: n.id, title: n.title, message: n.message, type: n.type, isRead: true, createdAt: n.createdAt, link: n.link) : n
    ).toList();
    notifyListeners();
  }

  Future<void> markAllNotifsRead() async {
    await PortalApi.markAllNotificationsRead();
    _notifications = _notifications.map((n) =>
      AppNotification(id: n.id, title: n.title, message: n.message, type: n.type, isRead: true, createdAt: n.createdAt, link: n.link)
    ).toList();
    notifyListeners();
  }

  Future<void> deleteNotif(String id) async {
    await PortalApi.deleteNotification(id);
    _notifications = _notifications.where((n) => n.id != id).toList();
    notifyListeners();
  }

  Future<void> clearAllNotifs() async {
    await PortalApi.clearAllNotifications();
    _notifications = [];
    notifyListeners();
  }

  void toggleReminders(bool enabled) {
    _remindersEnabled = enabled;
    _storage.remindersEnabled = enabled;
    if (enabled) {
      _scheduleRemindersIfNeeded();
    } else {
      NotificationService.cancelAll();
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _storage.themeMode = mode.name;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  void _scheduleRemindersIfNeeded() {
    if (_remindersEnabled && _student?.schedule != null && _student!.schedule!.isNotEmpty) {
      NotificationService.scheduleDailyReminder(_student!.schedule!);
    }
  }

  // ── Connectivity & Offline Loading ────────────────────────────────

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = _isOffline;
      _isOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (wasOffline && !_isOffline) {
        _onReconnect();
      }
      notifyListeners();
    });
    Connectivity().checkConnectivity().then((results) {
      _isOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      notifyListeners();
      if (!_isOffline && _isLoggedIn) {
        _refreshInBackground();
      }
    });
  }

  void _onReconnect() {
    _lastDataUpdate = DateTime.now();
    _refreshInBackground();
    _loadCommunity(refresh: true);
  }

  void _registerDevice() {
    final token = PushService.deviceToken;
    if (token != null && token.isNotEmpty) {
      PortalApi.registerDeviceToken(token);
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        final retryToken = PushService.deviceToken;
        if (retryToken != null && retryToken.isNotEmpty) {
          PortalApi.registerDeviceToken(retryToken);
        }
      });
    }
  }

  Future<void> loadGrades(ReportLink report) async {
    if (_loadedGrades.containsKey(report.href)) return;
    _loadingSemesterHref = report.href;
    notifyListeners();

    if (_isOffline) {
      _loadedGrades = _offlineService.cachedGrades;
      _loadingSemesterHref = null;
      notifyListeners();
      return;
    }

    final result = await PortalApi.getGrades(report.href, reportName: report.text);
    if (result['success'] == true) {
      _loadedGrades[report.href] = result['subjects'] as List<SubjectGrade>;
      _offlineService.saveGrades(_loadedGrades);
    }
    _loadingSemesterHref = null;
    notifyListeners();
  }

  Future<void> _loadCommunity({bool refresh = false}) async {
    if (refresh) {
      _communityOffset = 0;
      _communityPosts = [];
    }
    _isCommunityLoading = true;
    notifyListeners();

    if (_isOffline) {
      _communityPosts = _offlineService.cachedPosts;
      _isCommunityLoading = false;
      notifyListeners();
      return;
    }

    final response = await PortalApi.getCommunityPosts(
      topic: _selectedTopic,
      search: _searchQuery,
      sort: _sortOrder,
      offset: _communityOffset,
    );
    if (_communityOffset == 0) {
      _communityPosts = response.posts;
    } else {
      _communityPosts = [..._communityPosts, ...response.posts];
    }
    _hasMorePosts = response.hasMore;
    _communityOffset += response.posts.length;
    _isCommunityLoading = false;
    if (refresh) _offlineService.savePosts(_communityPosts);
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

extension ChatMessageCopy on ChatMessage {
  ChatMessage copyWith({String? content, String? status}) {
    return ChatMessage(id: id, role: role, content: content ?? this.content, status: status ?? this.status, tools: tools);
  }
}
