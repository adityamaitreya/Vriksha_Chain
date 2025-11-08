import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/batch_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/quality_metrics_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAB6lo7ZKQpSAf-CS9jY1HxG-OACZo21-4",
      authDomain: "vriksha-chain.firebaseapp.com",
      databaseURL: "https://vriksha-chain-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "vriksha-chain",
      storageBucket: "vriksha-chain.firebasestorage.app",
      messagingSenderId: "263466607025",
      appId: "1:263466607025:web:31d3334ac56f7d13fb1d90",
    ),
  );
  
  runApp(const VrikshaChainApp());
}

class VrikshaChainApp extends StatelessWidget {
  const VrikshaChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BatchProvider()),
        ChangeNotifierProvider(create: (_) => QualityMetricsProvider()),
      ],
      child: MaterialApp.router(
        title: 'VrikshaChain',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50), // Nature green
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}

