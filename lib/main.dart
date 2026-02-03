import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nexlinks/features/auth/logic/auth_event.dart';
import 'package:nexlinks/firebase_options.dart';
import 'package:nexlinks/router/app_router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/services/storage_service.dart';
// TODO: Enable in second update
// import 'package:nexlinks/core/services/notification_service.dart';
import 'package:nexlinks/core/services/connectivity_service.dart';
import 'package:nexlinks/core/widgets/status_manager.dart';
import 'package:nexlinks/core/widgets/connectivity_overlay.dart';
import 'package:nexlinks/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:nexlinks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nexlinks/features/auth/domain/repositories/auth_repository.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter/services.dart';


Future<void> main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Force dark system UI immediately to prevent flicker
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Initialize services with individual error handling
    // TODO: Enable in second update
    // try {
    //   await NotificationService().init();
    // } catch (e) {
    //   debugPrint("Notification Service Error: $e");
    // }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(DevicePreview(
      enabled: !kReleaseMode && (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)),
      builder: (context) => const MyApp(),
    ));
  } catch (e) {
    debugPrint("CRITICAL INITIALIZATION ERROR: $e");
    // Fallback runner if Firebase or root setup fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Startup Error: $e")),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Legacy Services (Keep until fully refactored if needed)
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => FirestoreService()),
        RepositoryProvider(create: (context) => StorageService()),
        RepositoryProvider(create: (context) => ConnectivityService()),
        
        // Clean Architecture Auth Feature
        RepositoryProvider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        )..add(AuthStarted()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NexLinks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _appRouter.router,
      builder: (context, child) {
        return StatusManager(
          child: ConnectivityOverlay(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.opaque,
              child: child!,
            ),
          ),
        );
      },
    );
  }
}


// NexLink (Next + Link)

// SyncMinds (Synchronizing brains)