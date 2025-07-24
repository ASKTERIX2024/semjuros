import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Número de páginas do tutorial
  final int _totalPages = 3;

  // Função para concluir o tutorial
  Future<void> _finishTutorial(BuildContext context) async {
    // Define o flag IS_FIRST_TIME como false no SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IS_FIRST_TIME', false);

    // Redireciona para a HomeScreen
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial"),
        automaticallyImplyLeading: false, // Remove o ícone de "voltar"
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Conteúdo das páginas do tutorial
                _buildPage(
                  title: "Bem-vindo!",
                  description: "Esse é o tutorial do app. Vamos começar?",
                ),
                _buildPage(
                  title: "Funcionalidade 1",
                  description: "Aqui está como você pode usar a funcionalidade 1.",
                ),
                _buildPage(
                  title: "Funcionalidade 2",
                  description: "Aqui está como usar a funcionalidade 2 do app!",
                ),
              ],
            ),
          ),

          // Barra inferior com os botões
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // Monta o conteúdo de cada página
  Widget _buildPage({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Monta a barra de navegação inferior
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão "Voltar" (aparece apenas se não for na primeira página)
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text("Voltar"),
            )
          else
            const SizedBox(), // Espaço vazio para alinhar com o botão da direita

          // Botão "Próximo" ou "Ir para o app" (dependendo da página)
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _totalPages - 1) {
                // Finaliza o tutorial quando for a última página
                _finishTutorial(context);
              } else {
                // Vai para a próxima página
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(
              _currentPage == _totalPages - 1 ? "Ir para o app" : "Próximo",
            ),
          ),
        ],
      ),
    );
  }
}