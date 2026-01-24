import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatelessWidget {
  MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: GoogleFonts.roboto(color: Colors.white),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.person_add_outlined, size: 28),
            ),
            title: Text(
              'Find people to message',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Connect to start chatting',
              style: GoogleFonts.roboto(color: Colors.grey),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Updates',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Society Of Snow',
            '3d',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Wall E',
            '1w',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to F1 4k Wallpaper',
            '1w',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Full Moon',
            '2w',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Crusher Setup',
            '2w',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Fakira Band',
            '3w',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to My Wallpaper',
            '3w',
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(String text, String time) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(Icons.search, size: 28),
      ),
      title: Text(text, style: GoogleFonts.roboto(fontSize: 15)),
      subtitle: Text(
        time,
        style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13),
      ),
      trailing: Icon(Icons.more_horiz),
    );
  }
}
