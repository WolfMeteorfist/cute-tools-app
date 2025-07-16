import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final String title;

  const ArticleDetailPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(title),
      ),
    );
  }
}