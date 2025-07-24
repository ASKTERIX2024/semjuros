void main() {
  String numero = "12.345.678.90";

  // Localizar o último ponto
  int ultimoPontoIndex = numero.lastIndexOf('.');

  // Substituir o último ponto por vírgula
  String resultado = numero.substring(0, ultimoPontoIndex) + ',' + numero.substring(ultimoPontoIndex + 1);

  print(resultado); // Saída: 12.345.678,90
}