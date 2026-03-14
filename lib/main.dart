import 'package:flutter/material.dart';

import 'portfolio/pages/portfolio_home_page.dart';
import 'portfolio/services/firebase_service.dart';
import 'portfolio/utils/portfolio_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PortfolioFirebaseService.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adnan Ullah — Mobile App Developer',
      theme: PortfolioTheme.dark(),
      home: const PortfolioHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


