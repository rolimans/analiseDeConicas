import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/conica.dart';
import 'dart:ui' as ui;
import 'dart:html';
import 'dart:js' as js;

import '../util/inputFormatter.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _cntx;
  final _formKey = GlobalKey<FormState>();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  final _d = TextEditingController();
  final _e = TextEditingController();
  final _f = TextEditingController();
  final _amountValidator = RegExInputFormatter.withRegex(
      r"(^$)|(^[.,]$)|(^[+-]$)|(^[+-]?([0-9]+([.,][0-9]*)?|[.,][0-9]+)$)");
  bool _autoValidate = false;

  Conica inicial;
  Conica simples;
  String tipo;
  String centro;
  String focos;
  String vertices;
  String eixo;
  String assintotas;

  @override
  void initState() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory("divPlot", (int viewId) {
      IFrameElement element = IFrameElement()
        ..src = 'assets/plot.html'
        ..style.border = 'none'
        ..id = 'plot';
      return element;
    });
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory("divPlot2", (int viewId) {
      IFrameElement element = IFrameElement()
        ..src = 'assets/plot.html'
        ..style.border = 'none'
        ..id = 'plot2';
      return element;
    });
    super.initState();
  }

  bool isValidNum(var str, {bool checkZero = false}) {
    if (str == '') return !checkZero;
    try {
      var v = str.replaceAll(',', '.');
      var n = num.parse(v);
      return !(checkZero && n == 0);
    } catch (e) {
      return false;
    }
  }

  num numFromStr(var str) {
    if (str == '') return 0;
    var v = str.replaceAll(',', '.');
    return num.parse(v);
  }

  String toCoordinate(var x) {
    return '(x: ${num.parse(x[0].toStringAsFixed(4))}, y: ${num.parse(x[1].toStringAsFixed(4))})';
  }

  void _reset() {
    setState(() {
      _autoValidate = false;
      inicial = simples = null;
      tipo = centro = focos = vertices = eixo = assintotas = null;
    });
  }

  void _analyze() {
    _reset();

    bool is_valid = _formKey.currentState.validate();

    if (is_valid &&
        (isValidNum(_a.text, checkZero: true) ||
            isValidNum(_b.text, checkZero: true) ||
            isValidNum(_c.text, checkZero: true))) {
      var a = numFromStr(_a.text);
      var b = numFromStr(_b.text);
      var c = numFromStr(_c.text);
      var d = numFromStr(_d.text);
      var e = numFromStr(_e.text);
      var f = numFromStr(_f.text);

      setState(() {
        inicial = Conica(a: a, b: b, c: c, d: d, e: e, f: f);

        var aux = inicial;

        if (aux.canCancelLinear) {
          aux = aux.cancelLinear;
        }

        simples = aux.cancelMulti;

        tipo = simples.tipoStr;

        if (simples.hasMore) {
          var str = '';
          var i = 0;
          var fs = simples.focos;

          if (fs[0] is num) {
            focos = toCoordinate(fs);
          } else {
            for (var fw in fs) {
              str += toCoordinate(fw);
              if (i != (fs.length - 1)) {
                if (i != (fs.length - 2)) {
                  str += ', ';
                } else {
                  str += ' e ';
                }
              }
              i++;
            }
            focos = str;
          }
          str = '';
          i = 0;

          var vs = simples.vertices;

          if (vs[0] is num) {
            vertices = toCoordinate(vs);
          } else {
            for (var v in vs) {
              str += toCoordinate(v);
              if (i != (vs.length - 1)) {
                if (i != (vs.length - 2)) {
                  str += ', ';
                } else {
                  str += ' e ';
                }
              }
              i++;
            }
            vertices = str;
          }

          if (simples.hasCenter) {
            centro = toCoordinate(simples.centro);
          }
          if (simples.hasAssintota) {
            assintotas = '${simples.assintotas[0]} e ${simples.assintotas[1]}';
          }
          if (simples.hasEixo) {
            eixo = simples.eixo;
          }
        }
      });

      js.context.callMethod('plot',
          [inicial.a, inicial.b, inicial.c, inicial.d, inicial.e, inicial.f]);

      js.context.callMethod('plot2', [
        simples.a,
        simples.b,
        simples.c,
        simples.d,
        simples.e,
        simples.f,
        (assintotas != null ? simples.assintotas[0] : null),
        (assintotas != null ? simples.assintotas[1] : null),
        (eixo != null ? eixo : null),
      ]);
    } else if (!is_valid) {
      setState(() {
        _autoValidate = true;
      });
    } else {
      Flushbar(
        icon: Icon(
          Icons.warning,
          color: Colors.red,
        ),
        duration: Duration(seconds: 2),
        messageText: Text(
          'Os valores de a, b e c não podem ser igual a 0 simultaneamente!',
          style: TextStyle(color: Colors.white),
        ),
      ).show(_cntx);
    }
  }

  @override
  Widget build(BuildContext context) {
    _cntx = context;
    return Scaffold(
        appBar: AppBar(
          title: Text('Análise De Cônicas'),
          actions: [
            IconButton(
              icon: Icon(FontAwesomeIcons.github),
              onPressed: () async {
                const url = 'https://github.com/rolimans/analiseDeConicas';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            )
          ],
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Insira a equação da cônica a ser analisada:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Form(
                  autovalidate: _autoValidate,
                  key: _formKey,
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _a,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "a",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('x²')),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _b,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "b",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('xy')),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _c,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "c",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('y²')),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _d,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "d",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('x')),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _e,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "e",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('y')),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 50,
                              child: TextFormField(
                                controller: _f,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "f",
                                ),
                                inputFormatters: [_amountValidator],
                                validator: (value) {
                                  if (!isValidNum(value)) {
                                    return "Inválido";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(5), child: Text('= 0')),
                          ],
                        ),
                      ])),
              Container(
                  padding: EdgeInsets.all(20),
                  child: RaisedButton.icon(
                    color: Colors.green,
                    onPressed: _analyze,
                    icon: Icon(Icons.check),
                    label: Text('Analisar'),
                  )),
              Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      simples != null
                          ? Text("Informações:",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))
                          : Container(),
                      inicial != null
                          ? Text("Equação inserida: $inicial = 0",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      simples != null
                          ? Text("Equação simplificada: $simples = 0",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      tipo != null
                          ? Text("Tipo da Cônica: $tipo",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      focos != null
                          ? Text("Foco(s): $focos",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      vertices != null
                          ? Text("Vértices: $vertices",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      centro != null
                          ? Text("Centro: $centro",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      assintotas != null
                          ? Text("Assíntotas: $assintotas",
                              style: TextStyle(fontSize: 15))
                          : Container(),
                      eixo != null
                          ? Text("Eixo: $eixo", style: TextStyle(fontSize: 15))
                          : Container(),
                    ],
                  )),
              Visibility(
                  visible: simples != null,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Gráficos:',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  )),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: [
                    Column(
                      children: [
                        Visibility(
                            visible: simples != null,
                            child: Text("Conica original:",
                                style: TextStyle(fontSize: 15))),
                        Container(
                          height: simples != null ? 405 : 0,
                          width: simples != null ? 400 : 0,
                          child: HtmlElementView(
                            viewType: 'divPlot',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Visibility(
                            visible: simples != null,
                            child: Text("Conica simplificada:",
                                style: TextStyle(fontSize: 15))),
                        Container(
                          height: simples != null ? 405 : 0,
                          width: simples != null ? 400 : 0,
                          child: HtmlElementView(
                            viewType: 'divPlot2',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
