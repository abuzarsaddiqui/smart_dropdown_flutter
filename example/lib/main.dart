import 'package:flutter/material.dart';
import 'package:smart_dropdown/smart_dropdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Dropdown Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Smart Dropdown Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<SmartDropdownMenuItem> items;
  SmartDropdownMenuItem getItem(dynamic value, String item){
    return SmartDropdownMenuItem(value: value, child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(item),
    ));

  }
  @override
  Widget build(BuildContext context) {
    items = [
      getItem(1, "Item 1"),
      getItem(2, "Item 2"),
      getItem(3, "Item 3"),
      getItem(4, "Item 4"),
      getItem(5, "Item 5"),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          height: 30, width: 300,
          child: SmartDropDown(
            items: items,
            hintText: "Smart Dropdown Demo",
            borderRadius: 5,
            borderColor: Theme.of(context).primaryColor,
            expandedColor: Theme.of(context).primaryColor,
          ),
        ),
      ),

    );
  }
}
