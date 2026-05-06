import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelfy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(
            decoration: InputDecoration(
              labelText: 'Rechercher un film, livre ou vinyle',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 24),
          ListTile(
            title: Text('Films'),
            leading: Icon(Icons.movie),
          ),
          ListTile(
            title: Text('Livres'),
            leading: Icon(Icons.menu_book),
          ),
          ListTile(
            title: Text('Vinyles'),
            leading: Icon(Icons.album),
          ),
          ListTile(
            title: Text('Ma bibliothèque'),
            leading: Icon(Icons.collections_bookmark),
          ),
          ListTile(
            title: Text('Liste de souhaits'),
            leading: Icon(Icons.favorite),
          ),
        ],
      ),
    );
  }
}
