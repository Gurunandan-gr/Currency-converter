import 'dart:convert';

import 'package:currency_converter/secret.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScaffoldScreen extends StatelessWidget {
  const ScaffoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffolScreen();
  }
}

class ScaffolScreen extends StatefulWidget {
  const ScaffolScreen({super.key});

  @override
  State<ScaffolScreen> createState() => _ScaffolScreenState();
}

class _ScaffolScreenState extends State<ScaffolScreen> {
  double result = 0.0;
  late Future<Map<String, dynamic>> currencyFuture;
  final TextEditingController _controller = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'INR';

  Future<Map<String, dynamic>> getCurrency() async {
    try {
      final res = await http.get(
          Uri.parse("https://v6.exchangerate-api.com/v6/$api_key/latest/USD"));
      final currency = jsonDecode(res.body);

      if (currency["result"] == "error") {
        throw 'unexpected error occurred';
      }
      return currency;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    currencyFuture = getCurrency();
  }

  void _convert(Map<String, dynamic> rates) {
    setState(() {
      double fromRate = rates[fromCurrency] ?? 1.0;
      double toRate = rates[toCurrency] ?? 1.0;
      double amount = double.tryParse(_controller.text) ?? 0.0;
      result = (amount / fromRate) * toRate;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: currencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;
            final rates = data["conversion_rates"];

            if (rates == null) {
              return const Center(child: Text('No rates available'));
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Currency Converter',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 17, 255),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter amount',
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount here...',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: fromCurrency,
                        items: rates.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            fromCurrency = newValue!;
                          });
                        },
                      ),
                      const Icon(Icons.arrow_right_sharp),
                      DropdownButton<String>(
                        value: toCurrency,
                        items: rates.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            toCurrency = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _convert(rates),
                    child: const Text('Convert'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$result",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ScaffoldScreen(),
  ));
}
