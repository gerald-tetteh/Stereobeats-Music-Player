import 'package:flutter/material.dart';

class BottomActionsBar extends StatelessWidget {
  final _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.play_arrow),
      title: Text("Play"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      title: Text("Add"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.share),
      title: Text("Share"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.delete),
      title: Text("Delete"),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: _items,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(
        color: Colors.grey[700],
      ),
      selectedItemColor: Colors.grey[700],
      unselectedItemColor: Colors.grey[700],
      selectedFontSize: 15,
      unselectedFontSize: 15,
    );
  }
}
