import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinterest/core/constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<List<Map<String, dynamic>>> getSavedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) return [];

    return List<Map<String, dynamic>>.from(doc.data()?['savedItems'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surfaceVariant,
              child: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 40),
            ),
            SizedBox(height: 16),
            Text(
              user!.email ?? 'Anonymous User',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '@anonymous_user',
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '0 followers · 0 following',
              style: GoogleFonts.roboto(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Share',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[700]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Edit profile',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Pins'),
                      Tab(text: 'Boards'),
                      Tab(text: 'Collages'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your Pins',
                        hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildFilterChip(Icons.grid_view, true),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          Icons.star,
                          false,
                          label: 'Favourites',
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(null, false, label: 'Created by you'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Board suggestions',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildBoardSuggestion('Fashion outfits', '0 Pins', [
                          Colors.red,
                          Colors.black,
                        ]),
                        _buildBoardSuggestion('Movies', '0 Pins', [
                          Colors.grey,
                          Colors.blueGrey,
                        ]),
                        _buildBoardSuggestion('Simple dresses', '0 Pins', [
                          Colors.blue,
                          Colors.lightBlue,
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your saved Pins',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  FutureBuilder<Widget>(
                    future: _buildPinsGrid(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading pins'));
                      }
                      return snapshot.data ?? SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, bool selected, {String? label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.grey[850],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: selected ? Colors.black : Colors.white),
          if (label != null) ...[
            if (icon != null) SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoardSuggestion(String title, String count, List<Color> colors) {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: colors),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Create',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(title, style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
          Text(
            count,
            style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildPinsGrid() async {
    final savedItems = await getSavedItems();
    developer.log(savedItems[0].toString());
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: savedItems.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.grey[850],
              child: Center(
                child: Image.network(
                  savedItems[index]['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.grey);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
