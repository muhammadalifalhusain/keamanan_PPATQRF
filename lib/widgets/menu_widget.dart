import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/main/pelanggaran_screen.dart';
class MenuIkonWidget extends StatefulWidget {
  const MenuIkonWidget({Key? key}) : super(key: key);

  @override
  State<MenuIkonWidget> createState() => _MenuIkonWidgetState();
}

class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({
    required this.icon,
    required this.label,
  });
}

class _MenuIkonWidgetState extends State<MenuIkonWidget> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final menuItems = _buildMenuItems();
    final displayedItems = _showAll ? menuItems : menuItems.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: Color(0xFF263238), size: 20),
              const SizedBox(width: 6),
              Text(
                'Menu Keamanan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF263238),
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 6,
          children: displayedItems
              .map((item) => _buildMenuItem(context, item))
              .toList(),
        ),
      ],
    );
  }

  List<_MenuItem> _buildMenuItems() {
    return [
      _MenuItem(icon: Icons.warning_amber, label: 'Pelanggaran'),
      _MenuItem(icon: Icons.assignment, label: 'Izin'),
      _MenuItem(icon: Icons.backpack, label: 'Perlengkapan'),
      _MenuItem(icon: Icons.cut, label: 'Kerapian'),
      _MenuItem(icon: Icons.rule, label: 'Ketertiban'),
    ];
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () {
        switch (item.label) {
          case 'Pelanggaran':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PelanggaranScreen()),
            );
            break;
          case 'Izin':
            // TODO: Ganti dengan screen Izin
            _showComingSoonDialog(context, item.label);
            break;
          case 'Perlengkapan':
            // TODO: Ganti dengan screen Perlengkapan
            _showComingSoonDialog(context, item.label);
            break;
          case 'Kerapian':
            // TODO: Ganti dengan screen Kerapian
            _showComingSoonDialog(context, item.label);
            break;
          case 'Ketertiban':
            // TODO: Ganti dengan screen Ketertiban
            _showComingSoonDialog(context, item.label);
            break;
          default:
            _showComingSoonDialog(context, item.label);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Info', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Fitur "$feature" sedang dalam pengembangan dan akan segera tersedia.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mengerti', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
