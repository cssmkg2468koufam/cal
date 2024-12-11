//IM_2021_74 - Chamudi Gunawardhana

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double baseFontSize = 50.0;
  static const double minFontSize = 20.0;

  List<String> symbols = [
    'Del',
    'AC',
    '%',
    '/',
    '7',
    '8',
    '9',
    '*',
    '4',
    '5',
    '6',
    '+',
    '1',
    '2',
    '3',
    '-',
    '.',
    '0',
    '√',
    '=',
  ];
  String input = '';
  String output = '';
  String previousInput = '';
  bool isResultDisplayed = false;

  String formatOutput(String output) {
    try {
      double number = double.parse(output);
      if (number == number.toInt()) {
        return number.toInt().toString();
      } else {
        return number
            .toStringAsFixed(8)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      return output;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final previousInputTextSize = screenWidth * 0.06;
    final buttonTextSize = screenWidth * 0.06;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: showHistoryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.bottomRight,
              child: Text(
                previousInput.isEmpty ? '' : previousInput,
                style: TextStyle(
                  fontSize: previousInputTextSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.bottomRight,
              child: Text(
                input.isEmpty ? '0' : input,
                style: TextStyle(
                  fontSize: calculateFontSize(input),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: symbols.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 05,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      onButtonPressed(symbols[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        symbols[index],
                        style: TextStyle(
                          color: myTextColor(symbols[index]),
                          fontWeight: FontWeight.w500,
                          fontSize: buttonTextSize,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateFontSize(String input) {
    final int length = input.length;
    return length > 10
        ? baseFontSize - (length - 10) * 3
        : baseFontSize.clamp(minFontSize, baseFontSize);
  }

  void onButtonPressed(String symbol) {
    setState(() {
      if (symbol == 'AC') {
        input = '';
        output = '';
        previousInput = '';
        isResultDisplayed = false;
      } else if (symbol == 'Del') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (symbol == '=') {
        try {
          if (input.contains('/0')) {
            input = "Can't divide by zero";
            return;
          }
          String expressionToEvaluate = input.replaceAllMapped(
            RegExp(r'√([0-9.]+)'),
            (match) => 'sqrt(${match.group(1)})',
          );
          expressionToEvaluate = expressionToEvaluate.replaceAllMapped(
            RegExp(r'([0-9.]+)%'),
            (match) => '(${match.group(1)}/100)',
          );
          Expression exp = Parser().parse(expressionToEvaluate);
          double result = exp.evaluate(EvaluationType.REAL, ContextModel());
          previousInput = input;
          output = formatOutput(result.toString());
          input = output;
          history.add('$previousInput = $output');
        } catch (e) {
          input = 'Error';
        }
        isResultDisplayed = true;
      } else if (['+', '-', '*', '/'].contains(symbol)) {
        if (isResultDisplayed) {
          isResultDisplayed = false;
          input = output;
        }

        //When the input field is empty, adding an operator (like +, -, *, /) directly would result in an invalid mathematical expression.
        //To prevent this, the code prepends '0' to the operator, ensuring the expression is valid.
        if (input.isEmpty) {
          input = '0$symbol';
        } else if (['+', '-', '*', '/'].contains(input[input.length - 1])) {
          input = input.substring(0, input.length - 1) + symbol;
        } else {
          input += symbol;
        }
      } else {
        if (input.length >= 15) {
          return; // Ignore input if it exceeds the limit
        }

        //Handle decimal points
        if (symbol == '.') {
          String lastNumber = getCurrentNumber(input);
          if (lastNumber.isEmpty) {
            input += '0.';
          } else if (!lastNumber.contains('.')) {
            input += '.';
          }

          //Manages the input of numeric symbols (0–9)
        } else if (RegExp(r'\d').hasMatch(symbol)) {
          String lastNumber = getCurrentNumber(input);
          if (lastNumber == '0') {
            input = input.substring(0, input.length - 1) + symbol;
          } else {
            if (isResultDisplayed) {
              input = symbol;
              isResultDisplayed = false;
            } else {
              input += symbol;
            }
          }
        } else if (symbol == '√') {
          if (input.isNotEmpty &&
              (input[input.length - 1] == '√' ||
                  ['+', '-', '*', '/'].contains(input[input.length - 1]))) {
            return;
          }
          input += '√';
        } else if (symbol == '%') {
          if (input.isNotEmpty &&
              !['+', '-', '*', '/', '√'].contains(input[input.length - 1])) {
            input += '%';
          }
        }
      }
    });
  }

  String getCurrentNumber(String input) {
    final matches = RegExp(r'[0-9]*\.?[0-9]+$').allMatches(input);
    return matches.isEmpty ? '' : matches.first.group(0) ?? '';
  }

  Color myTextColor(String x) {
    if (['%', '/', '*', '+', '-', '=', '√'].contains(x)) {
      return const Color.fromARGB(255, 52, 203, 214);
    } else if (['AC'].contains(x)) {
      return const Color.fromARGB(255, 231, 26, 26);
    } else if (['Del'].contains(x)) {
      return const Color.fromARGB(255, 46, 115, 219);
    }
    return const Color.fromARGB(255, 255, 255, 255);
  }

  void showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('History'),
                  Row(
                    children: [
                      if (history.isNotEmpty)
                        if (history.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Clear All History'),
                                    content: const Text(
                                        'Are you sure you want to clear all history?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text('Clear All'),
                                        onPressed: () {
                                          setState(() {
                                            history.clear();
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                height: 300, // Fixed height for the history box
                width: double.maxFinite,
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          'No History Available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(history[index]),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<String> history = [];
}
