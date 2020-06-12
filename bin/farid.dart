import 'package:farid/conica.dart';

/*
1. Eliminar, se possível, os termos lineares por translação. Okay
2. Eliminar o termo quadrático misto por rotação. Okay


3. Obter, como resultado, uma equação reduzida da cônica e identificar a mesma.

4. Obter os dados geométricos da cônica nos casos da elipse, hipérbole, parábola, isto é, determinar as coordenadas dos focos, 
centro, vértices, equações das assíntotas (no caso da hipérbole), equação do eixo (no caso da parábola)

*/
void main(List<String> arguments) {
  var tst = Conica(a: 1, b: 0, c: 0, d: 2, e: 4, f: 0);

  print(tst);
  if(tst.canCancelLinear)
    tst = tst.cancelLinear;

  print(tst);
  tst = tst.cancelMulti;

  print(tst);
  print(tst.tipo);

  print(tst.focos);

}