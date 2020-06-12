import 'dart:math';
import 'mathUtil.dart';

enum ConicaTypes {
  elipse,
  hiperbole,
  parabola,
  circulo,
  vazia,
  ponto,
  retas_identicas,
  retas_concorrentes,
  retas_paralelas
}

class Conica {
  num a = 0;
  num b = 0;
  num c = 0;
  num d = 0;
  num e = 0;
  num f = 0;
  List<num> translacaoFactor;
  num rotacaoFactor;

  Conica({num a, num b, num c, num d, num e, num f}) {
    if ((a == null || a == 0) &&
        (b == null || b == 0) &&
        (c == null || c == 0)) {
      throw 'Cônica Inválida';
    }
    this.a = a ?? 0;
    this.b = b ?? 0;
    this.c = c ?? 0;
    this.d = d ?? 0;
    this.e = e ?? 0;
    this.f = f ?? 0;
  }

  bool get canCancelLinear {
    return (determinanteDoisPorDois(matrixHelper) != 0) || hasInfSolutions;
  }

  bool get hasInfSolutions {
    if (determinanteDoisPorDois(matrixHelper) != 0) return false;

    var sis = [
      [a, b / 2, -d / 2],
      [b / 2, c, -e / 2],
    ];

    var aux = sis[0][0];

    for (var i = 0; i < 3; i++) {
      sis[0][i] /= aux;
    }

    aux = -(sis[1][0] / sis[0][0]);

    for (var i = 0; i < 3; i++) {
      sis[1][i] += (aux * sis[0][i]);
    }

    aux = 0;

    for (var i = 0; i < 3; i++) {
      aux += sis[1][i];
    }

    return (aux == 0);
  }

  Conica get cancelLinear {
    if (e == 0 && d == 0) return this;

    if (!canCancelLinear) {
      throw 'Cônica não tem centro ou tem infinitos centros';
    }

    if (hasInfSolutions) {
      var sis = [a, b / 2, -d / 2];
      translacaoFactor = [1];
      translacaoFactor.add((sis[2] - sis[0]) / sis[1]);
    } else {
      var sisVar = [
        [a, b / 2],
        [b / 2, c],
      ];
      var sisConst = [-d / 2, -e / 2];

      translacaoFactor = twoVariableSystemSolver(sisVar, sisConst);
    }

    var F =
        ((d / 2) * translacaoFactor[0]) + ((e / 2) * translacaoFactor[1]) + f;

    return Conica(a: a, b: b, c: c, f: F);
  }

  Conica get cancelMulti {
    if (b == 0) return this;

    var cotg = (a - c) / b;
    var twoTet = angleFromCot(cotg);
    rotacaoFactor = twoTet / 2;

    var sisVar = [
      [1, 1],
      [1, -1]
    ];
    var sisConst = [a + c, (b * (sqrt(1 + pow((a - c) / b, 2))))];

    var sisAns = twoVariableSystemSolver(sisVar, sisConst);

    var A = sisAns[0];
    var C = sisAns[1];
    var E, D = 0;

    if (d != 0 || e != 0) {
      D = (d * cos(rotacaoFactor)) + e * sin(rotacaoFactor);
      E = (-d * sin(rotacaoFactor)) + e * cos(rotacaoFactor);
    }

    return Conica(a: A, c: C, e: E, d: D, f: f);
  }

  List<List<num>> get matrixHelper {
    return [
      [a, b / 2, d / 2],
      [b / 2, c, e / 2],
      [d / 2, e / 2, f]
    ];
  }

  ConicaTypes get tipo {
    if (b == 0 && d == 0 && e == 0) {
      if (f == 0) {
        if (a == 0 || c == 0) {
          return ConicaTypes.retas_identicas;
        }
        if ((a > 0 && c < 0) || (a < 0 && c > 0)) {
          return ConicaTypes.retas_concorrentes;
        } else {
          return ConicaTypes.ponto;
        }
      } else {
        if (a == 0 || c == 0) {
          var aux = a == 0 ? c : a;
          if ((aux > 0 && f < 0) || (aux < 0 && f > 0)) {
            return ConicaTypes.retas_paralelas;
          } else {
            return ConicaTypes.vazia;
          }
        }
        if ((a > 0 && c < 0) || (a < 0 && c > 0)) {
          return ConicaTypes.hiperbole;
        } else {
          if ((f > 0 && a < 0) || (f < 0 && a > 0)) {
            return ConicaTypes.elipse;
          } else {
            return ConicaTypes.vazia;
          }
        }
      }
    } else if (b == 0) {
      return ConicaTypes.parabola;
    } else {
      throw 'Simplifique a Cônica antes';
    }
  }

  bool get _validMore {
    return (tipo == ConicaTypes.hiperbole ||
        tipo == ConicaTypes.parabola ||
        tipo == ConicaTypes.elipse);
  }

  List get focos {
    if (!_validMore) throw 'Cônica Inválida';
    if (tipo == ConicaTypes.elipse) {
      var A = -f / a;
      var B = -f / c;
      var C = A - B;

      C = sqrt(C);

      A = sqrt(A);

      if (C > A) {
        return [
          [0, -A],
          [0, A]
        ];
      }
      return [
        [-C, 0],
        [C, 0]
      ];
    }
    if (tipo == ConicaTypes.hiperbole) {
      var A = -f / a;
      var B = -f / c;
      var C = A - B;

      C = sqrt(C);

      A = sqrt(A);

      if (C > A) {
        return [
          [0, -A],
          [0, A]
        ];
      }
      return [
        [-C, 0],
        [C, 0]
      ];
    }
  }

  List get centro {
    if (!_validMore) throw 'Cônica Inválida';
    return [0, 0];
  }

  @override
  String toString() {
    var str = a != 0 ? a > 0 ? '+$a x² ' : '$a x² ' : '';
    str += b != 0 ? b > 0 ? '+$b xy ' : '$b xy ' : '';
    str += c != 0 ? c > 0 ? '+$c y² ' : '$c y² ' : '';
    str += d != 0 ? d > 0 ? '+$d x ' : '$d x ' : '';
    str += e != 0 ? e > 0 ? '+$e y ' : '$e y ' : '';
    str += f != 0 ? f > 0 ? '+$f ' : '$f ' : '';
    return str;
  }
}
