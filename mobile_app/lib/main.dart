import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/blocs/dashboard_bloc.dart';
import 'features/dashboard/repository/document_repository.dart';
import 'features/dashboard/view/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              repository: context.read<IDocumentRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'OmniDoc AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
