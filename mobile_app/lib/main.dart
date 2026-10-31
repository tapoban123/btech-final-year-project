import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/blocs/chat_bloc.dart';
import 'features/chat/repository/chat_repository.dart';
import 'features/dashboard/blocs/dashboard_bloc.dart';
import 'features/dashboard/repository/document_repository.dart';
import 'features/dashboard/view/screens/dashboard_screen.dart';
import 'features/upload/blocs/upload_bloc.dart';
import 'features/upload/repository/upload_repository.dart';

const _globalSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.surfaceContainerLowest,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarContrastEnforced: false,
  systemStatusBarContrastEnforced: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent app from going to landscape mode globally
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system navigation bar and status bar colors globally on Android
  SystemChrome.setSystemUIOverlayStyle(_globalSystemUiOverlayStyle);

  runApp(const OmniDocApp());
}

class OmniDocApp extends StatelessWidget {
  const OmniDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IDocumentRepository>(
          create: (_) => DocumentRepository(),
        ),
        RepositoryProvider<IChatRepository>(
          create: (_) => ChatRepository(),
        ),
        RepositoryProvider<IUploadRepository>(
          create: (_) => UploadRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              repository: context.read<IDocumentRepository>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              repository: context.read<IChatRepository>(),
            ),
          ),
          BlocProvider<UploadBloc>(
            create: (context) => UploadBloc(
              repository: context.read<IUploadRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'OmniDoc AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: _globalSystemUiOverlayStyle,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
