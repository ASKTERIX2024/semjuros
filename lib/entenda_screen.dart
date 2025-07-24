import 'package:flutter/material.dart';
import 'dart:io';


class EntendaScreen extends StatelessWidget {
  final int tipo;

  EntendaScreen(this.tipo);
  final Color verdeDoApp = Color(0xFF428C93);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: verdeDoApp,
      body: Column(
        children: [
          SafeArea(
           child: Container(
           height: 60,
           padding: EdgeInsets.symmetric(horizontal: 20),
           alignment: Alignment.center,
           color: Colors.white,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              Text(
                tipo == 1 ? 'Entenda o cálculo' : 'Explicação',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
          Expanded(
            child: Center(
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(5),
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.asset(
                  tipo == 1 ? 'assets/images/Entenda o cálculo.png' : 'assets/images/Explicação.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}