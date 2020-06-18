import 'dart:io';
import 'package:analiseDeConicas/conica.dart';

/*
1. Eliminar, se possível, os termos lineares por translação.
2. Eliminar o termo quadrático misto por rotação.
3. Obter, como resultado, uma equação reduzida da cônica e identificar a mesma.
4. Obter os dados geométricos da cônica nos casos da elipse, hipérbole, parábola, isto é, determinar as coordenadas dos focos, 
centro, vértices, equações das assíntotas (no caso da hipérbole), equação do eixo (no caso da parábola)
*/

void main(List<String> arguments) {
  var read = stdin.readLineSync;

  print(
      'Insira a equação da conica no seguinte formato: ax² + bxy + cy² + dx + ey +f');

  print('a:');
  var a = num.parse(read());
  print('b:');
  var b = num.parse(read());
  print('c:');
  var c = num.parse(read());
  print('d:');
  var d = num.parse(read());
  print('e:');
  var e = num.parse(read());
  print('f:');
  var f = num.parse(read());

  if (a == 0 && b == 0 && c == 0) {
    print('Os valores de a,b e c não podem ser igual a 0 simultaneamente!');
    return;
  }

  try {
    var conica = Conica(a: a, b: b, c: c, d: d, e: e, f: f);

    print('Cônica Inicial: $conica.');

    if (conica.canCancelLinear) {
      conica = conica.cancelLinear;
    }

    conica = conica.cancelMulti;

    print('Cônica Simplificada: $conica.');

    print('Tipo da Cônica: ${conica.tipoStr}');

    if (conica.hasMore) {
      print('Focos: ${conica.focos}');
      print('Vértices: ${conica.vertices}');
      if (conica.hasCenter) {
        print('Centro: ${conica.centro}');
      }
      if (conica.hasAssintota) {
        print('Assíntotas: ${conica.assintotas}');
      }
      if (conica.hasEixo) {
        print('Eixo: ${conica.eixo}');
      }
    }
  } catch (e) {
    print('Erro!');
    print(e);
  }
}
