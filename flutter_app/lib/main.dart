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
      title: 'Life Expectancy Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
      appBar: AppBar(
        title: const Text('Life Expectancy Predictor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_hdiRankController, 'HDI Rank (1-200)'),
                const SizedBox(height: 12),
                _buildTextField(_le1990Controller, 'Life Expectancy 1990 (30-90)'),
                const SizedBox(height: 12),
                _buildTextField(_le2000Controller, 'Life Expectancy 2000 (30-90)'),
                const SizedBox(height: 12),
                _buildTextField(_le2010Controller, 'Life Expectancy 2010 (30-90)'),
                const SizedBox(height: 12),
                _buildTextField(_le2020Controller, 'Life Expectancy 2020 (30-90)'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _predict,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Predict'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                if (_predictionResult.isNotEmpty)
                  Text(
                    _predictionResult,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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
}
