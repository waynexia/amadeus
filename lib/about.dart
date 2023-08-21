import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Amadeus'),
          shadowColor: Theme.of(context).colorScheme.shadow,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text(
                'Amadeus',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 16.0),
              const Text(
                'Built by Ruihang Xia',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              InkWell(
                onTap: () =>
                    launchUrl(Uri.parse("https://github.com/waynexia/amadeus")),
                hoverColor: Colors.transparent,
                child: const Text(
                  'https://github.com/waynexia/amadeus',
                  style: TextStyle(fontSize: 16.0, color: Colors.blue),
                ),
              ),
            ],
          ),
        ));
  }
}
