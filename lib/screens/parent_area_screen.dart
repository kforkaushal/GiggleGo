import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Parent Area screen — reached only through the parental gate.
/// Contains audio settings, star summary, progress reset, and privacy policy.
class ParentAreaScreen extends StatefulWidget {
  const ParentAreaScreen({super.key});

  @override
  State<ParentAreaScreen> createState() => _ParentAreaScreenState();
}

class _ParentAreaScreenState extends State<ParentAreaScreen> {
  bool _soundEnabled = true;
  bool _loading = true;
  final Map<String, int> _categoryStars = {};
  int _totalStars = 0;

  static const List<Map<String, String>> _categories = [
    {'id': 'colors', 'name': 'Colors', 'emoji': '🌈'},
    {'id': 'fruits', 'name': 'Fruits', 'emoji': '🍎'},
    {'id': 'animals', 'name': 'Animals', 'emoji': '🦁'},
    {'id': 'vehicles', 'name': 'Vehicles', 'emoji': '🚗'},
    {'id': 'shapes', 'name': 'Shapes', 'emoji': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sound = await StorageService.getSoundEnabled();
    int total = 0;
    final Map<String, int> stars = {};
    for (final cat in _categories) {
      final s = await StorageService.getStars(cat['id']!);
      stars[cat['id']!] = s;
      total += s;
    }

    if (mounted) {
      setState(() {
        _soundEnabled = sound;
        _categoryStars.addAll(stars);
        _totalStars = total;
        _loading = false;
      });
    }
  }

  Future<void> _toggleSound(bool value) async {
    await StorageService.setSoundEnabled(value);
    if (mounted) {
      setState(() => _soundEnabled = value);
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reset All Progress?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will reset all earned stars across all categories back to zero. This action cannot be undone.',
          style: TextStyle(color: Color(0xFF546E7A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF78909C))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.resetAllStars();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All progress has been reset.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: Color(0xFF455A64)),
            SizedBox(width: 8),
            Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Giggle Go! — Privacy Notice',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'We take children’s privacy very seriously. Giggle Go! is designed to be a safe, offline learning environment for toddlers and preschoolers (ages 2–6).\n\n'
                '• No Personal Data: We do NOT collect, store, or transmit any personally identifiable information.\n'
                '• No Ads or Analytics: There are no advertising SDKs, third-party trackers, or analytics tools in this app.\n'
                '• Local Storage Only: All game progress (stars earned) is stored purely on your local device.\n'
                '• Offline Ready: No internet connection is required to use any feature.\n'
                '• Policy Compliance: Fully aligned with the Google Play Families Policy and the Children’s Online Privacy Protection Act (COPPA).\n\n'
                'If you have questions, please reach out to us at:\nsupport@gigglego.app',
                style: TextStyle(fontSize: 13, color: Color(0xFF455A64), height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF455A64),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF37474F),
        elevation: 0.5,
        title: const Text(
          'For Parents',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              children: [
                // Section: Audio Settings
                _buildSectionHeader('SETTINGS'),
                _buildCard(
                  child: SwitchListTile(
                    title: const Text(
                      'Sound Effects',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    subtitle: const Text(
                      'Play cheerful sounds and feedback in games',
                      style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
                    ),
                    value: _soundEnabled,
                    activeThumbColor: const Color(0xFF4CAF50),
                    onChanged: _toggleSound,
                  ),
                ),
                const SizedBox(height: 20),

                // Section: Progress Overview
                _buildSectionHeader('LEARNING PROGRESS'),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Stars Earned',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD54F)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_totalStars',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Color(0xFFF57F17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ..._categories.map((cat) {
                          final count = _categoryStars[cat['id']] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(cat['emoji']!, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Text(
                                  cat['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$count ⭐',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF78909C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _confirmReset,
                          icon: const Icon(Icons.refresh, size: 18, color: Color(0xFFEF5350)),
                          label: const Text(
                            'Reset Progress',
                            style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section: About & Privacy
                _buildSectionHeader('ABOUT & PRIVACY'),
                _buildCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF607D8B)),
                        title: const Text(
                          'Privacy Policy',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'COPPA compliant • Zero data collection',
                          style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFB0BEC5)),
                        onTap: _showPrivacyPolicy,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Color(0xFF607D8B)),
                        title: const Text(
                          'About Giggle Go!',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Version 1.0.0 (Offline Preschool Edition)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF90A4AE),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
