import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/attractions_data.dart';

class PopularProvider extends ChangeNotifier {
  final List<Attraction> _attractions = List.from(attractions);
  List<Attraction> _favorites = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  PopularProvider() {
    // Listen to Firebase Auth state changes so favorites are loaded or cleared per account
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _favorites = [];
        notifyListeners();
      } else {
        _loadFavoritesFromFirestore(user.uid);
      }
    });
  }

  List<Attraction> get allAttractions => _attractions;
  List<Attraction> get favorites => List.unmodifiable(_favorites);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => [
        'All',
        'Historical',
        'Museums',
        'Towers',
      ];

  Future<void> _loadFavoritesFromFirestore(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return Attraction(
          title: data['title'] ?? '',
          location: data['location'] ?? '',
          description: data['description'] ?? '',
          image: data['image'] ?? '',
          category: data['category'] ?? 'Historical',
          wikiKey: data['wikiKey'] ?? data['title'] ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (_) {
      _favorites = [];
      notifyListeners();
    }
  }

  List<Attraction> get filteredAttractions {
    return _attractions.where((attraction) {
      final matchesQuery = _searchQuery.trim().isEmpty ||
          attraction.title.toLowerCase().contains(_searchQuery.toLowerCase().trim()) ||
          attraction.location.toLowerCase().contains(_searchQuery.toLowerCase().trim()) ||
          attraction.description.toLowerCase().contains(_searchQuery.toLowerCase().trim());

      final matchesCategory = _selectedCategory == 'All' ||
          attraction.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();
  }

  bool isFavorite(Attraction attraction) {
    return _favorites.any((item) => item.title == attraction.title);
  }

  void toggleFavorite(Attraction attraction) {
    final user = FirebaseAuth.instance.currentUser;
    final currentlyFav = isFavorite(attraction);

    // 1. Update UI immediately (Optimistic update)
    if (currentlyFav) {
      _favorites.removeWhere((item) => item.title == attraction.title);
    } else {
      _favorites.add(attraction);
    }
    notifyListeners();

    // 2. Sync with Firestore in background for the current user's UID
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(attraction.title.replaceAll(' ', '_'));

      if (currentlyFav) {
        docRef.delete().catchError((_) {});
      } else {
        docRef.set({
          'title': attraction.title,
          'location': attraction.location,
          'description': attraction.description,
          'image': attraction.image,
          'category': attraction.category,
          'wikiKey': attraction.wikiKey,
        }).catchError((_) {});
      }
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void searchAttractions(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
