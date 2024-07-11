library ola_map_autocomplete;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'location_autocomplete_provider.dart';
import 'debouncer.dart';

class OlaLocationAutocomplete extends StatefulWidget {
  final String apiKey;
  final InputDecoration decoration;
  final TextStyle textStyle;

  OlaLocationAutocomplete({
    required this.apiKey,
    this.decoration = const InputDecoration(),
    this.textStyle = const TextStyle(),
  });

  @override
  _OlaLocationAutocompleteState createState() => _OlaLocationAutocompleteState();
}

class _OlaLocationAutocompleteState extends State<OlaLocationAutocomplete> {
  TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationAutocompleteProvider(apiKey: widget.apiKey),
      child: Consumer<LocationAutocompleteProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TextField(
                controller: _controller,
                decoration: widget.decoration,
                style: widget.textStyle,
                onChanged: (input) {
                  _debouncer.run(() {
                    provider.fetchSuggestions(input);
                  });
                },
              ),
              provider.isLoading
                  ? CircularProgressIndicator()
                  : provider.results.isNotEmpty
                      ? Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: provider.results.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(provider.results[index]['description']),
                                onTap: () {
                                  Navigator.of(context).pop({
                                    'description': provider.results[index]['description'],
                                    'lat': provider.results[index]['geometry']['location']['lat'],
                                    'lng': provider.results[index]['geometry']['location']['lng'],
                                  });
                                },
                              );
                            },
                          ),
                        )
                      : Container(),
            ],
          );
        },
      ),
    );
  }
}
