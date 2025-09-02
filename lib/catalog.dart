import 'package:astra_mobile/selected.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class CatalogPage extends StatefulWidget {
  static var page;

  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogRouteState();
}

bool _showShimmer = true;

class _CatalogRouteState extends State<CatalogPage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse(
      'https://api.store.astra-lombard.kz/api/v1/categories/search',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"pageSize": 100, "categoryId": ""}),
      );

      final data = json.decode(response.body);
      setState(() {
        categories = data['data'];
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryTile(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    Widget tile = Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: () {
          print("Tapped category: ${category['name']}");
          Navigator.pushNamed(
            context,
            '/selected',
            arguments: {'id': category['id'], 'name': category['name']},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category['imagePath'],
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 70),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return _showShimmer
        ? Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: tile,
          )
        : tile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        title: const Text(
          'Каталог',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                children: List.generate(categories.length, (index) {
                  final cat = categories[index];

                  bool isLast =
                      index == categories.length - 1 && categories.length.isOdd;

                  return StaggeredGridTile.fit(
                    crossAxisCellCount: isLast ? 2 : 1,
                    child: buildCategoryTile(context, cat),
                  );
                }),
              ),
            ),
    );
  }
}
