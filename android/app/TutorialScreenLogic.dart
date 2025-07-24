import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Total de páginas do tutorial
  final int _totalPages = 3;

  // Função para concluir o tutorial e navegar para a HomeScreen
  Future<void> _finishTutorial(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IS_FIRST_TIME', false);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pages = [
      {
        'image': 'assets/images/Explicação.png',
        'title': 'Bem-vindo ao App!',
      },
      {
        'image': 'assets/images/Explicação.png',
        'title': 'Funcionalidade X',
      },
      {
        'image': 'assets/images/Explicação.png',
        'title': 'A Tela Principal',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        automaticallyImplyLeading: false, // Remove o ícone de "voltar"
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return _buildPage(
                  title: page['title']!,
                  image: page['image']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão "Voltar"
                _currentPage > 0
                    ? TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Voltar'),
                      )
                    : const SizedBox.shrink(),

                // Botão "Próximo" ou "Ir para o App"
                _currentPage == pages.length - 1
                    ? ElevatedButton(
                        onPressed: () => _finishTutorial(context),
                        child: const Text('Ir para o app'),
                      )
                    : TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Próximo'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cria o layout de cada página: Título no topo e imagem no centro
  Widget _buildPage({
    required String title,
    required String image,
  }) {
    return Column(
      children: [
        // Título fixo no topo
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // O espaço restante será preenchido pela imagem
        Expanded(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}