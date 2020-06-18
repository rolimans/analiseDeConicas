import 'dart:math';

List<num> twoVariableSystemSolver(
    List<List<num>> variables, List<num> constants) {
  if (variables.length != 2) {
    throw 'Sistema inválido';
  }

  for (var i = 0; i < 2; i++) {
    if (variables[i].length != 2) {
      throw 'Sistema inválido';
    }
  }
  if (constants.length != 2) {
    throw 'Número incorreto de constantes';
  }

  var determinanteDoSis = determinanteDoisPorDois(variables);

  if (determinanteDoSis == 0) {
    throw 'Sistema não tem solução ou tem infinitas soluções';
  }

  List<num> ans = List<num>();

  var matA = [
    [constants[0], variables[1][0]],
    [constants[1], variables[1][1]]
  ];

  var matB = [
    [variables[0][0], constants[0]],
    [variables[0][1], constants[1]]
  ];

  ans.add(determinanteDoisPorDois(matA) / determinanteDoSis);

  ans.add(determinanteDoisPorDois(matB) / determinanteDoSis);

  return ans;
}

num determinanteDoisPorDois(List<List<num>> m) {
  return ((m[0][0] * m[1][1]) - (m[0][1] * m[1][0]));
}

num angleFromCot(num cot){
  return atan(1/cot);
}

num delta(a,b,c){
  b = pow(b,2);
  return b - (4*a*c);
}


num mod(num a){
  if(a>=0) return a;
  return -a;
}