import 'package:flutter/material.dart';
import 'dart:math';
import 'entenda_screen.dart'; // Certifique-se de ter esse arquivo separado
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';


class AppGlobal {
  // Recupera a taxa referencial salva ou retorna 15.0 como padrão
   static Future<double> _getTaxaReferencial() async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     return prefs.getDouble('TAXA_REFERENCIAL') ?? 14.9; // Padrão: 15%
   }

   // Salva a taxa referencial no SharedPreferences
   static Future<void> _setTaxaReferencial(double novaTaxa) async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.setDouble('TAXA_REFERENCIAL', novaTaxa);
   }
}

void main()  {
  runApp(const SemJurosApp());
}
const Color verdeDoApp = Color(0xFF428C93);

class SemJurosApp extends StatelessWidget {
  const SemJurosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(), // Registra apenas as demais rotas
      },

      title: 'Sem Juros (Só que Não)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromRGBO(63, 142, 14, 1.0), // Sua cor de semente
            ).copyWith(
              // Substituir fundo e superfícies por branco absoluto
              background: Color(0xFFFFFFFF), // Fundo branco
              surface: Color(0xFFFFFFFF),   // Branco para superfícies
            ),
        useMaterial3: true,
      ),
      home: CheckFirstTimeScreen(), // Verifica se deve abrir o tutorial ou a HomeScreen
    );

  }
}

class CheckFirstTimeScreen extends StatelessWidget {
  const CheckFirstTimeScreen({Key? key}) : super(key: key);

  Future<bool> _isFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Verifica se é a primeira vez executando o app
    return prefs.getBool('IS_FIRST_TIME') ?? true;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTime(), // Chama a função para checar se é a primeira vez
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostra um indicador de carregamento enquanto espera a decisão
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Baseado no resultado do SharedPreferences, decide qual tela abrir
        if (snapshot.data == true) {
          return TutorialScreen(); // Abre o tutorial na primeira vez
        } else {
          return const HomeScreen(); // Vai direto para a Home nas vezes seguintes
        }
      },
    );
  }
}


class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Total de páginas do tutorial
  final int _totalPages = 8;

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
        'image': 'assets/images/Tutorial_1.png',
        'title': 'Visão Geral!',
      },
      {
        'image': 'assets/images/Tutorial_2.png',
        'title': 'Entrada de dados',
      },
      {
        'image': 'assets/images/Tutorial_3.png',
        'title': 'Resultado',
      },
      {
        'image': 'assets/images/Tutorial_4.png',
        'title': 'Recomenedação',
        },
        {
        'image': 'assets/images/Tutorial_5.png',
        'title': 'Matemática',
      },
      {
        'image': 'assets/images/Tutorial_6.png',
        'title': 'Dedução da fórmula',
    },
    {
        'image': 'assets/images/Tutorial_7.png',
        'title': 'Derivada da função',
    },
    {
  'image': 'assets/images/Tutorial_8.png',
        'title': 'Newton Raphson',
    },
    ];

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Sem Juros?'),
      //   automaticallyImplyLeading: false, // Remove o ícone de "voltar"
      // ),
      backgroundColor: Color(0xFFFFFFFF),
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
                  buttons: [
                    // Botão "Anterior"
                              if (index > 0) // Exibe o botão somente se não for a primeira página
                                ElevatedButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: const Text('Anterior'),
                                ),

                              // Botão "Próximo" ou "Ir para o App"
                              if (index == pages.length - 1) // Na última página
                                ElevatedButton(
                                  onPressed: () => _finishTutorial(context),
                                  child: const Text('Ir para o app'),
                                )
                              else // Nas demais páginas
                                ElevatedButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: const Text('Próximo'),
                                ),
                            ],



                );
              },
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildPage({
    required String title,
    required String image,
    required List<Widget> buttons, // Lista de botões no rodapé
  }) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Título fixo no topo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Área reservada para a imagem com Rolagem Vertical
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InteractiveViewer(
                      panEnabled: true, // Permite arrastar a imagem com os dedos
                      scaleEnabled: true, // Permite ampliar/reduzir a imagem através do zoom
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.asset(
                        image,
                        fit: BoxFit.fitWidth, // Ajusta a IMAGEM à largura da tela
                        width: double.infinity, // Garante que ocupe toda a largura possível
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botões fixos no rodapé
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pixController = TextEditingController();
  final _parceladoController = TextEditingController();
  final _TxReferencialController = TextEditingController();
  final _parcelasController = TextEditingController();
  final _ValorParcelaController = TextEditingController();
  final _ValorParcelaFocus = FocusNode();
  String versaoApp = '';
  String buildApp = '';
  final _pixFocus = FocusNode();
  String adjetivo = 'recomendável';
  final _TxReferencialFocus = FocusNode();
  final _parceladoFocus = FocusNode();
  final _parcelasFocus = FocusNode();
  String pix_parcelamento = '';
  double ganho = 0;
  Timer? _debounce;
  bool _taxaCalculada = false;
  bool _persistenteDica = true;

  String _taxaFormatada = '';

  int count(String texto, String caractere) {
    return texto.split(caractere).length - 1;
  }

  double _converter(String texto) {
    // Remove pontos de milhar e troca vírgula por ponto decimal
    final limpo = texto.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(limpo);
  }


  void _limparCampos() {
    _parceladoController.clear();
    _ValorParcelaController.clear();
    _parcelasController.clear();
    _pixController.clear();
    _taxaCalculada = false;
    _parceladoController.clear();
    _taxaFormatada = '';
    FocusScope.of(context).unfocus(); // remove foco dos campos
    //ScaffoldMessenger.of(context).showSnackBar(
      //const SnackBar(content: Text('Campos limpos!')),
    //);
    FocusScope.of(context).requestFocus(_pixFocus);
  }
  void _FormatarDecimal(TextEditingController controller) {
    String Buffer = "";
    if (count(controller.text, '.') >= 1 && count(controller.text, ',') == 0 ) {
      int ultimoPontoIndex = controller.text.lastIndexOf('.');
      Buffer = controller.text.substring(0, ultimoPontoIndex) + ',' + controller.text.substring(ultimoPontoIndex + 1);
      Buffer = Buffer.replaceAll('.', '');
    }
    else if (count(controller.text, '.') >= 1 && count(controller.text, ',') == 1 ) {
          Buffer = controller.text.replaceAll('.', '');
    }
    else if (count(controller.text, ',') >= 1) {
      int ultimoPontoIndex = controller.text.lastIndexOf(',');
      Buffer = controller.text.substring(0, ultimoPontoIndex) + '#' + controller.text.substring(ultimoPontoIndex + 1);
      Buffer = Buffer.replaceAll(',', '');
      Buffer = Buffer.replaceAll('.', '');
      Buffer = Buffer.replaceAll('#', ',');
    }
    else Buffer = controller.text;
    final valor = double.tryParse(Buffer.replaceAll(',', '.'));
    if (valor != null) {
      final formatador = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '', // sem símbolo R$
        decimalDigits: 2,
      );
      controller.text = formatador.format(valor).trim();
    }
  }

  Future<void> _carregarTaxaReferencial() async {
    final double taxa = await AppGlobal._getTaxaReferencial(); // Lê o valor salvo
    setState(() {
      _TxReferencialController.text = taxa.toString().replaceAll('.',','); // Preenche o campo de texto
    });
  }



  double calcula_juros(
    double pix,
    double prestacao,
    int parcelas, {
    double chuteInicial = 1,
    double tolerancia = 1e-9,
    int maxIter = 100,
    }) {
      chuteInicial = ((prestacao * parcelas) - pix)/(parcelas * pix);
      double j = chuteInicial;
      for (int i = 0; i < maxIter; i++) {
        final powN  = pow(1 + j, parcelas);
        final powN1 = pow(1 + j, parcelas - 1);

        double f      = pix * j * powN - prestacao * (powN - 1);
        double fPrime = pix * powN + pix * parcelas * j * powN1 - prestacao * parcelas * powN1;

        double jNext = j - f / fPrime;

        if ((jNext - j).abs() < tolerancia) {
          return jNext;
        }
        j = jNext;
      }
      return chuteInicial;
      throw Exception('Não convergiu após $maxIter iterações.');

    }


  void _onTotalParceladoChanged(String texto) {
    double parcela = 0;
    final double parcelado = _converter(texto);
    final int? parcelas = int.tryParse(_parcelasController.text);
    if (parcelas != null && parcelas > 0 && parcelado != null) {
        parcela = parcelado / parcelas;
        _ValorParcelaController.text = parcela.toString();
        _FormatarDecimal(_ValorParcelaController);
     }
   _calcularTaxa();
  }


  void _onParcelasChanged(String texto) {
    final parcelas = int.tryParse(texto);
    if (parcelas != null && parcelas > 0) {
      if (_parceladoController.text != '' && _ValorParcelaController.text != '') {
        double parcelado = _converter(_parceladoController.text);
        final parcela = parcelado / parcelas;
        _ValorParcelaController.text = parcela.toString();
        _FormatarDecimal(_ValorParcelaController);
      }
      else if (_ValorParcelaController.text != '') {
        double parcela = _converter(_ValorParcelaController.text);
        final parcelado = parcelas * parcela;
        _parceladoController.text = parcelado.toString();
        _FormatarDecimal(_parceladoController);
      }
      else if (_parceladoController.text != '' && _ValorParcelaController.text == '') {
        double parcelado = _converter(_parceladoController.text);
        final parcela = parcelado / parcelas;
        _ValorParcelaController.text = parcela.toString();
        _FormatarDecimal(_ValorParcelaController);
      }
      _calcularTaxa();
    }
  }

  void _onValorParcelaChanged(String texto) {
    final int? parcelas = int.tryParse(_parcelasController.text);
    double parcela = _converter(_ValorParcelaController.text);
    if (parcela != null && parcelas != null && parcelas > 0) {
      final double parcelado = parcela * parcelas;
      _parceladoController.text = parcelado.toString();
      _FormatarDecimal(_parceladoController);
    }
    _calcularTaxa();
  }
  void _carregarInfoApp() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      versaoApp = info.version;
      buildApp = info.buildNumber;
    });
  }

  void _onpixChanged(String texto) {
    _FormatarDecimal(_pixController);
    _persistenteDica = false;
     _calcularTaxa();
  }
  void _calcularTaxa() {
    if (_pixController.text =='' || _parceladoController.text == '' || _ValorParcelaController.text =='' || _parcelasController.text == '') {
      setState(() {_taxaFormatada = '';});
      return;
    }
    else {
      int parcelas = int.parse(_parcelasController.text);
      double pix = _converter(_pixController.text);
      double parcelado = _converter(_parceladoController.text);
      double valorParcela = _converter(_ValorParcelaController.text);

      if (parcelado >= pix) {
        double taxa = 5;
        taxa = calcula_juros(pix, parcelado / parcelas, parcelas);
        adjetivo = 'recomendável';
        ganho = pix * (pow(1+double.parse(_TxReferencialController.text.replaceAll(',','.')) / 100.0, parcelas/12)-1) - (parcelado - pix);
        pix_parcelamento = (ganho < 0) ? 'utilizando PIX. Com isso, o' : 'com parcelamento. Com isso, o';
        if (ganho < 0.01 && ganho > -0.01) {pix_parcelamento = 'com qualquer meio, pois o'; adjetivo = 'indiferente';}
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          FocusScope.of(context).unfocus();
        });
        _persistenteDica = false;
        if (taxa < 9999) {
          _taxaCalculada = true;
        } else {
          setState(() {
            _taxaFormatada = "não convergiu";
          });
        }
        if (_taxaFormatada == "não convergiu") return;
        setState(() {
          _taxaFormatada = '${(taxa * 100).toStringAsFixed(2).replaceAll('.',',')}%';
        });
      } else {
        setState(() {
          _taxaFormatada = "alerta";
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _carregarTaxaReferencial(); // Chama o método para carregar a taxa salva
    _carregarInfoApp();
    _pixFocus.addListener(() {
      if (!_pixFocus.hasFocus) {
        _FormatarDecimal(_pixController);
      }
    });
    _parceladoFocus.addListener(() {
      if (!_parceladoFocus.hasFocus) {
        _FormatarDecimal(_parceladoController);
      }
    });
    _ValorParcelaFocus.addListener(() {
      if (!_ValorParcelaFocus.hasFocus) {
        _FormatarDecimal(_ValorParcelaController);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    try {
      try {
        return Scaffold(
            backgroundColor: verdeDoApp, // cor inspirada no ícone
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom + 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Garante espaço entre os itens
                        crossAxisAlignment: CrossAxisAlignment.center,     // Alinha verticalmente no mesmo nível
                        children: [
                          const Text(
                            'Sem Juros?',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.orange),
                            onPressed: _limparCampos,
                            tooltip: 'Limpar campos',
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.white, size: 40),
                            tooltip: 'Explicação',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TutorialScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      Column(
                        children:[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,     // Alinha verticalmente no mesmo nível
                            children: [
                              const SizedBox(
                                width: 200,
                                child: Text(
                                  'Preço com Pix:',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(child: _buildCampoSemRotulo(_pixController, _pixFocus,onChanged: _onpixChanged,))
                            ],
                          ),
                          const SizedBox(height: 8),


                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,     // Alinha verticalmente no mesmo nível
                            children: [
                              SizedBox(
                                width: 200,
                                child:
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total parcelado:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                              SizedBox(height: 12), // espaço entre a legenda e o campo
                              Expanded(child: _buildCampoSemRotulo(_parceladoController, _parceladoFocus, onChanged: _onTotalParceladoChanged,)),

                            ],
                          ),

                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,     // Alinha verticalmente no mesmo nível
                            children: [
                              SizedBox(
                                width: 200,
                                child:
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Valor da parcela:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                              SizedBox(height: 12), // espaço entre a legenda e o campo
                              Expanded(child: _buildCampoSemRotulo(_ValorParcelaController, _ValorParcelaFocus,onChanged: _onValorParcelaChanged)),

                            ],
                          ),

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(
                                width: 200,
                                child: Text(
                                  'Parcelas:',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(child: _buildCampoSemRotulo(_parcelasController, _parcelasFocus, onChanged: _onParcelasChanged,
                              )),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_taxaFormatada == "alerta") ...[
                        const Text(
                          'Valor por pix é superior \n ao total parcelado, \n verifique os dados',
                          style: TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                      ],
                      if (_taxaFormatada == "não convergiu") ...[
                        const Text(
                          'Valores extremos. \n Não convergiu! \n Verifique os dados.',
                          style: TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                      ],
                      if (_taxaFormatada.isNotEmpty && _taxaFormatada != "alerta" && _taxaFormatada != "não convergiu") ...[
                        const Text(
                          'Juros embutidos',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end, // alinha a base dos textos
                          children: [
                            Text(
                              _taxaFormatada,
                              style: const TextStyle(fontSize: 40, color: Colors.white),
                            ),
                            const Text(
                              'ao mês',
                              style: TextStyle(fontSize: 18, color: Colors.white70),
                            ),
                          ],
                        ), //row
                        Column(
                          children: [
                            const SizedBox(height:12),
                            const Text('Recomendação:',
                                                     style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                                     textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(''' Com base na taxa média de investimentos de Renda Fixa, é $adjetivo realizar a compra $pix_parcelamento ganho financeiro será de ${(ganho.abs().toStringAsFixed(2)).replaceAll('.',',')} reais.''',
                                style: TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.normal),
                                                                                                     textAlign: TextAlign.justify),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 240,
                                  child: Text(
                                  'Inv. Renda Fixa (% ao ano):',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(child: _buildCampoSemRotulo(_TxReferencialController, _TxReferencialFocus, onChanged: (value) {
                                          String value2 = value.replaceAll(',','.');
                                          final double? novaTaxa = double.tryParse(value2); // Tenta converter para double
                                          if (novaTaxa != null) {
                                            AppGlobal._setTaxaReferencial(novaTaxa); // Salva no SharedPreferences
                                            _calcularTaxa();
                                          }
                                        },
                                )),
                              ],
                            ),
                          ]
                        )
                      ],

                      if (_taxaFormatada.isNotEmpty && _taxaFormatada != "alerta")
                      const SizedBox(height: 25), // espaço extra abaixo do botão "Entenda"
                      Text(
                        '© Abarei Tecnologia \nSem Juros? versão $versaoApp ($buildApp)',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      (_persistenteDica && ! (MediaQuery.of(context).viewInsets.bottom > 0)) ?
                      Text(
                        '\n💡 Dicas: \n\nUse a lixeira aí em cima \n para limpar os campos\n\nEntre com Valor da Parcela ou \nTotal Parcelado, é indiferente',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.amber,
                          fontStyle: FontStyle.normal,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                )
            )
        );
      } catch (e, s) {
        return Scaffold(
          body: Center(
            child: Text(
              'Ocorreu um erro ao carregar.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        );
      }
    } catch (e, s) {
      return Scaffold(
        body: Center(
          child: Text(
            'Ocorreu um erro ao carregar.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

  }



  Widget _buildCampoSemRotulo(TextEditingController controller, FocusNode focusNode, {
    void Function(String)? onChanged,
  }) {
    Timer? _debounce; // Criamos uma variável para o debounce dentro do escopo
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black, fontSize: 20),
      textAlign: TextAlign.right,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')
        ),
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (value) {
        // Cancela o timer anterior se ainda estiver ativo
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        // Define um tempo de debounce
        _debounce = Timer(const Duration(seconds: 2), () {
          if (onChanged != null) {
            onChanged(value); // Chama o callback após o debounce
          }
        });
      },
    );
  }


  @override
  void dispose() {
    _pixController.dispose();
    _parceladoController.dispose();
    _parcelasController.dispose();
    _TxReferencialController.dispose();
    _ValorParcelaController.dispose();
    _parcelasFocus.dispose();
    _pixFocus.dispose();
    _parceladoFocus.dispose();
    _TxReferencialFocus.dispose();
    _ValorParcelaFocus.dispose();
    super.dispose();
  }
}
