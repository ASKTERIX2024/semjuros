   import 'package:flutter/material.dart';

   void main() {
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: Scaffold(
           body: GestureDetector(
             gestureSettings: GestureSettings(
               touchSlop: 0, // Configurando para detectar gestos imediatamente
             ),
             onPanStart: (details) {
               print("Pan Start Detectado!");
             },
             onPanUpdate: (details) {
               print("Atualização do Gesto: ${details.localPosition}");
             },
             child: Center(
               child: Container(
                 width: 200,
                 height: 200,
                 color: Colors.blue,
                 child: Center(child: Text("Movimente aqui")),
               ),
             ),
           ),
         ),
       );
     }
   }