import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/attractions_data.dart';
import '../provider/pop.dart';
import '../services/wikipedia_service.dart';

class DetailsScreen extends StatelessWidget {
  final Attraction attraction;

  const DetailsScreen({
    super.key,
    required this.attraction,
  });

  Future<void> _openGoogleMaps(BuildContext context) async {
    final query =
        Uri.encodeComponent("${attraction.title} ${attraction.location}");
    final googleMapsUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      final launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularProvider = context.watch<PopularProvider>();
    final isFav = popularProvider.isFavorite(attraction);

    return Scaffold(
      appBar: AppBar(
        title: Text(attraction.title),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () {
              context.read<PopularProvider>().toggleFavorite(attraction);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: WikipediaService.fetchAttractionInfo(attraction.wikiKey),
        builder: (context, snapshot) {
          final wikiData = snapshot.data;
          final description = wikiData?['description'] ?? attraction.description;
          final imageUrl = wikiData?['image'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image: Network from Wikipedia if available, otherwise Local Asset
                imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          attraction.image,
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        attraction.image,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attraction.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 5),
                          Text(
                            attraction.location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _openGoogleMaps(context),
                            icon: const Icon(Icons.map_outlined, size: 18),
                            label: const Text("View Map"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? "Fetching live data from Wikipedia..."
                                  : "Live info fetched from Wikipedia ✨",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "About Attraction",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
