// ARQUIVO: lib/main.dart

import 'package:flutter/material.dart';
import 'screens/lista_tela.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Cor base do Mercado Livre
    const seedColor = Color(0xFFFFE600);

    return MaterialApp(
      title: 'App de Anúncios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // Garante o uso do Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          // Força o amarelo como primário para manter a identidade,
          // pois o seed às vezes gera tons pastéis.
          primary: seedColor,
          onPrimary: Colors.black87, // Garante texto escuro no amarelo
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: seedColor,
          foregroundColor: Colors.black87, // Cor dos ícones e texto na AppBar
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3483FA), // Azul clássico para ações
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          // Adicione 'const' aqui:
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          clipBehavior: Clip.antiAlias,
          // E adicione 'const' aqui:
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const ListaTela(),
    );
  }
}
