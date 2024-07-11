import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationAutocompleteProvider with ChangeNotifier {
  final String apiKey;
  List _results = [];
  bool _isLoading = false;

  List get results => _results;
  bool get isLoading => _isLoading;

  LocationAutocompleteProvider({required this.apiKey});

  void fetchSuggestions(String input) async {
    if (input.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final response = await http.get(
        Uri.parse('https://api.olamaps.io/places/v1/autocomplete?input=$input&api_key=$apiKey')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _results = data['predictions'];
    } else {
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
