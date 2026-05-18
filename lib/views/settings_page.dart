import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AppBar(
              title: const Text('Settings'),
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  icon: Image.asset('assets/images/drink_water.png'),
                  onPressed: () {
                    // TODO: Add button functionality
                  },
                ),
              ),
            ),
          ),
        ),
        body: const Center(
          child: Text('Settings Page Content'),
        ),
      ),
    );
  }

}
