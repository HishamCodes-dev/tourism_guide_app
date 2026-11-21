import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../provider/pop.dart';
import '../widgets/attraction_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final popularProvider = context.watch<PopularProvider>();
    final attractionsList = popularProvider.filteredAttractions;
    final categories = popularProvider.categories;
    final selectedCategory = popularProvider.selectedCategory;

    return Column(
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  context.read<PopularProvider>().searchAttractions(value);
                },
                decoration: InputDecoration(
                  hintText: "Search attractions or locations...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: popularProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            context.read<PopularProvider>().clearSearch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.white,
                        backgroundColor: AppColors.primary.withOpacity(0.8),
                        checkmarkColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                        onSelected: (_) {
                          context
                              .read<PopularProvider>()
                              .selectCategory(category);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: attractionsList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "No attractions match your search",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: attractionsList.length,
                  itemBuilder: (context, index) {
                    return AttractionCard(
                      attraction: attractionsList[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
