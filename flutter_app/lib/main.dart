import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life Expectancy Predictor',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final _hdiRankController = TextEditingController();
  final _le1990Controller = TextEditingController();
  final _le2000Controller = TextEditingController();
  final _le2010Controller = TextEditingController();
  final _le2020Controller = TextEditingController();

  String _predictionResult = '';
  bool _isLoading = false;

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _predictionResult = '';
      });

      const apiUrl = 'https://linear-regression-model-eyk5.onrender.com/predict';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'hdi_rank': double.parse(_hdiRankController.text),
            'le_1990': double.parse(_le1990Controller.text),
            'le_2000': double.parse(_le2000Controller.text),
            'le_2010': double.parse(_le2010Controller.text),
            'le_2020': double.parse(_le2020Controller.text),
          }),
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          setState(() {
            _predictionResult = 
                'Predicted Life Expectancy: ${result['predicted_life_expectancy_2021']}';
          });
        } else {
          setState(() {
            _predictionResult = 'Error: ${response.body}';
          });
        }
      } catch (e) {
        setState(() {
          _predictionResult = 'Error: Failed to connect to the API. Please check the URL and your connection.';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a237e), Color(0xFF004d40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Life Expectancy Predictor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                  _buildTextField(_hdiRankController, 'HDI Rank', Icons.leaderboard, hint: 'Enter a number between 1-200'),
                  const SizedBox(height: 16),
                  _buildTextField(_le1990Controller, 'Life Expectancy 1990', Icons.history, hint: 'Enter a number between 30-90'),
                  const SizedBox(height: 16),
                  _buildTextField(_le2000Controller, 'Life Expectancy 2000', Icons.history, hint: 'Enter a number between 30-90'),
                  const SizedBox(height: 16),
                  _buildTextField(_le2010Controller, 'Life Expectancy 2010', Icons.history, hint: 'Enter a number between 30-90'),
                  const SizedBox(height: 16),
                  _buildTextField(_le2020Controller, 'Life Expectancy 2020', Icons.history, hint: 'Enter a number between 30-90'),
                  const SizedBox(height: 32),
                  _buildPredictButton(),
                  const SizedBox(height: 32),
                  if (_predictionResult.isNotEmpty) _buildResultCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.tealAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildPredictButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.tealAccent, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _predict,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'PREDICT',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _predictionResult,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
