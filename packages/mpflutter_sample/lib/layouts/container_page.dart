import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class ContainerPage extends StatelessWidget {
  Widget _renderBlock(Widget child) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello'),
      ),
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: MaterialButton(
            onPressed: () {
              print("fdkjhsalf");
            },
            color: Colors.blue,
            height: 44,
            child: Text(
              'Hello button',
            ),
          ),
        ),
      ),
    );
  }
}
