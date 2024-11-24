// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/model/fuel_comparator.dart';
import 'package:namer_app/service/local_storage_service.dart';
import 'package:namer_app/utils/fuel_enum.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {},
      child: MaterialApp(
        title: 'Atividade 2',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: MyHomePage(0),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  int page = 0;

  MyHomePage(this.page);
  @override
  State<MyHomePage> createState() => _MyHomePageState(page);
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  _MyHomePageState(this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = FormFuelComparator();
        break;
      case 1:
        page = SaveComparatorPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.compare_arrows),
                        label: 'Comparador de combustível',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.save),
                        label: 'Comparações Salvas',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.compare_arrows),
                        label: Text('Comparador de combustível'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.save),
                        label: Text('Comparações Salvas'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class FormFuelComparator extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  Fuel fuel1 = Fuel.GASOLINE_REGULAR;
  Fuel fuel2 = Fuel.GASOLINE_REGULAR;
  double price1 = 0;
  double price2 = 0;
  double consumption1 = 0;
  double consumption2 = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        margin: EdgeInsets.all(0),
        height: 99999,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 50),
                  child: Text(
                    'Comparador de Combustível',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<Fuel>(
                        key: Key('fuel1'),
                        items: getDropdownItems(),
                        onChanged: (Fuel? newValue) {},
                        decoration: InputDecoration(
                          labelText: 'Selecione o Combustível',
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um combustível';
                          }
                          return null;
                        },
                        onSaved: (newValue) => fuel1 = newValue!,
                      ),
                      TextFormField(
                        key: Key('price1'),
                        decoration: InputDecoration(
                          labelText: 'Preço',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(),
                        ],
                        validator: (value) =>
                            validateInputText(value ?? '', 'Preço'),
                        onSaved: (newValue) {
                          // Remove the currency symbol and replace comma with dot
                          String cleanedValue = newValue!
                              .replaceAll(RegExp(r'[^\d,]'), '')
                              .replaceAll(',', '.');
                          price1 = double.parse(cleanedValue);
                        },
                      ),
                      TextFormField(
                          key: Key('consumption1'),
                          decoration: InputDecoration(
                            labelText: 'Consumo (km/l)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [NumberBrInputFormatter()],
                          validator: (value) =>
                              validateInputText(value ?? '', 'Consumo (km/l)'),
                          onSaved: (newValue) {
                            String cleanedValue = newValue!
                                .replaceAll(RegExp(r'[^\d,]'), '')
                                .replaceAll(',', '.');
                            consumption1 = double.parse(cleanedValue);
                          }),
                      // icon de comparação
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Icon(
                          Icons.compare_arrows,
                          size: 50,
                        ),
                      ),
                      DropdownButtonFormField<Fuel>(
                        key: Key('fuel2'),
                        items: getDropdownItems(),
                        onChanged: (Fuel? newValue) {},
                        decoration: InputDecoration(
                          labelText: 'Selecione o Combustível',
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um combustível';
                          }
                          return null;
                        },
                        onSaved: (newValue) => fuel2 = newValue!,
                      ),
                      TextFormField(
                          key: Key('price2'),
                          decoration: InputDecoration(
                            labelText: 'Preço',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                          validator: (value) =>
                              validateInputText(value ?? '', 'Preço'),
                          onSaved: (newValue) {
                            String cleanedValue = newValue!
                                .replaceAll(RegExp(r'[^\d,]'), '')
                                .replaceAll(',', '.');
                            price2 = double.parse(cleanedValue);
                          }),

                      TextFormField(
                          key: Key('consumption2'),
                          decoration: InputDecoration(
                            labelText: 'Consumo (km/l)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            NumberBrInputFormatter(),
                          ],
                          validator: (value) =>
                              validateInputText(value ?? '', 'Consumo (km/l)'),
                          onSaved: (newValue) {
                            String cleanedValue = newValue!
                                .replaceAll(RegExp(r'[^\d,]'), '')
                                .replaceAll(',', '.');
                            consumption2 = double.parse(cleanedValue);
                          }),
                      Container(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              _formKey.currentState!.save();
                              showDialog(
                                context: context,
                                builder: (context) => _ResponsePopupView(
                                  fuel1: fuel1,
                                  fuel2: fuel2,
                                  price1: price1,
                                  price2: price2,
                                  consumption1: consumption1,
                                  consumption2: consumption2,
                                ),
                              );
                            }
                          },
                          child: Text('Calcular'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )));
  }

  validateInputText(String value, String inputName) {
    if (value.isEmpty) {
      return 'O campo $inputName é obrigatório';
    }
    return null;
  }

  getDropdownItems() {
    return Fuel.values.map<DropdownMenuItem<Fuel>>((Fuel value) {
      return DropdownMenuItem(value: value, child: Text(value.label));
    }).toList();
  }
}

class _ResponsePopupView extends StatelessWidget {
  Fuel fuel1;
  Fuel fuel2;
  double price1;
  double price2;
  double consumption1;
  double consumption2;
  LocalStorageService localStorageService = LocalStorageService();

  _ResponsePopupView(
      {required this.fuel1,
      required this.fuel2,
      required this.price1,
      required this.price2,
      required this.consumption1,
      required this.consumption2});

  @override
  Widget build(BuildContext context) {
    var fuel1Description = fuel1.label;
    var fuel2Description = fuel2.label;
    return AlertDialog(
      title: const Text('Resultado'),
      content: Row(children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: '$fuel1Description gasto por km: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '${calculateByFuel(price1, consumption1).toString().replaceAll('.', ',')} R\$ \n\n'),
              TextSpan(
                  text: '$fuel2Description gasto por km: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '${calculateByFuel(price2, consumption2).toString().replaceAll('.', ',')} R\$ \n\n'),
              TextSpan(
                  text: 'O combustível mais econômico é: \n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: comparateFuel(
                      fuel1, fuel2, price1, price2, consumption1, consumption2))
            ],
          ),
        ),
      ]),
      actions: [
        TextButton(
          child: const Text('Salvar'),
          onPressed: () {
            localStorageService.save(FuelComparator(
                '',
                price1,
                price2,
                consumption1,
                consumption2,
                fuel1,
                fuel2,
                calculateByFuel(price1, consumption1),
                calculateByFuel(price2, consumption2)));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  comparateFuel(Fuel fuel1, Fuel fuel2, double price1, double price2,
      double consumption1, double consumption2) {
    double result1 = calculateByFuel(price1, consumption1);
    double result2 = calculateByFuel(price2, consumption2);
    String fuel1Description = fuel1.label;
    String fuel2Description = fuel2.label;

    if (result1 > result2) {
      return fuel2Description;
    } else if (result1 < result2) {
      return fuel1Description;
    }
    return 'Ambos';
  }

  calculateByFuel(double price, double consumption) {
    return double.parse((price / consumption).toStringAsFixed(2));
  }
}

class SaveComparatorPage extends StatelessWidget {
  LocalStorageService localStorageService = LocalStorageService();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Future<List<FuelComparator>> data = localStorageService.getAll();
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 50),
          child: Text(
            'Comparações Salvas',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<List<FuelComparator>>(
                  future: data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return Text('Erro ao carregar dados');
                    }
                    if (snapshot.hasData) {
                      return DataTable(
                        columnSpacing: 20,
                        columns: [
                          DataColumn(
                              label: Text('Combustível 1',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Preço 1',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Consumo 1',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Resultado 1',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Combustível 2',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Preço 2',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Consumo 2',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Resultado 2',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Melhor Combustível',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Remover',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: snapshot.data!.map((e) {
                          return DataRow(cells: [
                            DataCell(Text(e.fuel1.label)),
                            DataCell(Text(e.price1.toString())),
                            DataCell(Text(e.consumption1.toString())),
                            DataCell(Text(e.price_result1.toString())),
                            DataCell(Text(e.fuel2.label)),
                            DataCell(Text(e.price2.toString())),
                            DataCell(Text(e.consumption2.toString())),
                            DataCell(Text(e.price_result2.toString())),
                            DataCell(Text(e.price_result1 > e.price_result2
                                ? e.fuel2.label
                                : e.price_result1 < e.price_result2
                                    ? e.fuel1.label
                                    : 'Ambos')),
                            DataCell(IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                localStorageService.delete(e.id);
                                //recarreca a tela
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return MyHomePage(1);
                                }));
                              },
                            )),
                          ]);
                        }).toList(),
                      );
                    } else {
                      return Container(
                        child: Text('Nenhuma comparação salva'),
                      );
                    }
                  },
                ),
              ],
            ))
      ],
    ));
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove any non-numeric characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: new TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(newText);

    final formatter = NumberFormat.simpleCurrency(locale: "pt_BR");

    String formattedText = formatter.format(value / 100);

    return newValue.copyWith(
      text: formattedText,
      selection: new TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class NumberBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove any non-numeric characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: new TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(newText);

    final formatter = NumberFormat.decimalPattern("pt_BR");

    String formattedText = formatter.format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: new TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
