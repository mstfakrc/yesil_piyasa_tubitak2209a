import 'package:flutter/material.dart';

class AddProductsView extends StatefulWidget {
  const AddProductsView({super.key});

  @override
  State<AddProductsView> createState() => _AddProductsViewState();
}

class _AddProductsViewState extends State<AddProductsView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('add products'),
      ),
    );
  }
}