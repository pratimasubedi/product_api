import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:product_api/models/model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = fetchProducts();
  }

  Future<Product> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final product = Product.fromJson(jsonBody);

      return product;
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  void _showProductDetails(ProductElement productElement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(productElement.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${productElement.id}'),
              SelectableText('Description: ${productElement.description}'),
              Text('Price: \$${productElement.price.toStringAsFixed(2)}'),
              Text('Discount Percentage: ${productElement.discountPercentage}'),
              Text('Rating: ${productElement.rating}'),
              Text('Stock: ${productElement.stock}'),
              Text('Brand: ${productElement.brand}'),
              SelectableText('Category: ${productElement.category}'),
              Image.network(
                productElement.thumbnail,
                fit: BoxFit.cover,
                height: 100,
                width: 100,
              ),
              Text('Images:'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: productElement.images.map((image) {
                  return Image.network(
                    image,
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Product List'),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final product = snapshot.data!;

            return ListView.builder(
              itemCount: product.products.length,
              itemBuilder: (context, index) {
                final productElement = product.products[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    onTap: () {
                      _showProductDetails(productElement);
                    },
                    title: Text(
                      productElement.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productElement.description),
                        SizedBox(height: 4),
                        Text(
                          'ID: ${productElement.id}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '\$${productElement.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Text('No products found.');
          }
        },
      ),
    );
  }
}
