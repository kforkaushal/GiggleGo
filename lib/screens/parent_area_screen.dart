import 'package:flutter/material.dart';
import '../data/category_meta.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'home_screen.dart';

/// Parent Area screen — reached only through the parental gate.
/// Contains separate audio controls, quiet mode, accessibility, progress summary,
/// sticker collection shelf, tutorial replay, and privacy policy.
class ParentAreaScreen extends StatefulWidget {
  const ParentAreaScreen({super.key});

  @override
  State<ParentAreaScreen> createState() => _ParentAreaScreenState();
}

class _ParentAreaScreenState extends State<ParentAreaScreen> {
  bool _loading = true;

  bool _masterSound = true;
  bool _musicEnabled = true;
  bool _effectsEnabled = true;
  bool _quietMode = false;
  bool _reducedMotion = false;

  bool _tutorialCompleted = false;
  String? _lastPlayed;
  int _totalStars = 0;
  int _categoriesTried = 0;
  List<String> _stickers = [];
  final Map<String, int> _categoryStars = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sound = await StorageService.getSoundEnabled();
    final music = await StorageService.getMusicEnabled();
    final effects = await StorageService.getEffectsEnabled();
    final quiet = await StorageService.getQuietMode();
    final motion = await StorageService.getReducedMotion();
    final tutorial = await StorageService.getTutorialCompleted();
    final lastCat = await StorageService.getLastPlayedCategory();
    final stickers = await StorageService.getUnlockedStickers();

    int total = 0;
    int tried = 0;
    final Map<String, int> stars = {};
    for (final cat in allCategories) {
      final s = await StorageService.getStars(cat.id);
      stars[cat.id] = s;
      total += s;
      if (s > 0) tried++;
    }

    if (mounted) {
      setState(() {
        _masterSound = sound;
        _musicEnabled = music;
        _effectsEnabled = effects;
        _quietMode = quiet;
        _reducedMotion = motion;
        _tutorialCompleted = tutorial;
        _lastPlayed = lastCat;
        _totalStars = total;
        _categoriesTried = tried;
        _stickers = stickers;
        _categoryStars.addAll(stars);
        _loading = false;
      });
    }
  }

  Future<void> _toggleMasterSound(bool value) async {
    await StorageService.setSoundEnabled(value);
    setState(() => _masterSound = value);
    await SoundService.onSoundToggled(value, currentContext: 'home');
  }

  Future<void> _toggleMusic(bool value) async {
    await StorageService.setMusicEnabled(value);
    setState(() => _musicEnabled = value);
    if (value && !_quietMode) {
      await SoundService.resumeDesiredMusic();
    } else {
      await SoundService.stopMusic();
    }
  }

  Future<void> _toggleEffects(bool value) async {
    await StorageService.setEffectsEnabled(value);
    setState(() => _effectsEnabled = value);
  }

  Future<void> _toggleQuietMode(bool value) async {
    await StorageService.setQuietMode(value);
    setState(() => _quietMode = value);
    if (value) {
      await SoundService.stopMusic();
    } else {
      await SoundService.resumeDesiredMusic();
    }
  }

  Future<void> _toggleReducedMotion(bool value) async {
    await StorageService.setReducedMotion(value);
    setState(() => _reducedMotion = value);
  }

  void _replayTutorial() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen(forceTutorial: true)),
      (route) => false,
    );
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
          'This will reset all earned stars across all categories back to zero. Tutorial completion status will remain intact.',
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
            content: Text('All star progress has been reset.'),
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
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: Color(0xFF37474F),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              children: [
                // Section 1: Progress Summary Cards
                _buildSectionHeader('LEARNING OVERVIEW'),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Total Stars',
                                value: '$_totalStars',
                                icon: Icons.star_rounded,
                                iconColor: const Color(0xFFF57F17),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Categories Tried',
                                value: '$_categoriesTried / 6',
                                icon: Icons.category_rounded,
                                iconColor: const Color(0xFF00B074),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Last Played',
                                value: _lastPlayed != null ? _lastPlayed!.toUpperCase() : 'None yet',
                                icon: Icons.history_rounded,
                                iconColor: const Color(0xFF0088FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Tutorial Status',
                                value: _tutorialCompleted ? 'Completed' : 'Pending',
                                icon: _tutorialCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                                iconColor: _tutorialCompleted ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section 2: Audio & Quiet Mode Settings
                _buildSectionHeader('AUDIO & QUIET MODE'),
                _buildCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Master Sound', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Overall sound toggle for the app', style: TextStyle(fontSize: 12.5)),
                        value: _masterSound,
                        activeThumbColor: const Color(0xFF4CAF50),
                        onChanged: _toggleMasterSound,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Background Music', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Looping tunes on home and activity screens', style: TextStyle(fontSize: 12.5)),
                        value: _musicEnabled && !_quietMode,
                        activeThumbColor: const Color(0xFF4CAF50),
                        onChanged: _masterSound && !_quietMode ? _toggleMusic : null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Sound Effects (SFX)', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Cheerful pops and celebration feedback sounds', style: TextStyle(fontSize: 12.5)),
                        value: _effectsEnabled,
                        activeThumbColor: const Color(0xFF4CAF50),
                        onChanged: _masterSound ? _toggleEffects : null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Quiet Mode 🌙', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Silences background music for bedtime or travel while keeping feedback pops', style: TextStyle(fontSize: 12.5)),
                        value: _quietMode,
                        activeThumbColor: const Color(0xFF5E35B1),
                        onChanged: _masterSound ? _toggleQuietMode : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 3: Accessibility & Onboarding
                _buildSectionHeader('ACCESSIBILITY & ONBOARDING'),
                _buildCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Reduced Motion', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Replaces bouncing cards with gentle outline glows and fades', style: TextStyle(fontSize: 12.5)),
                        value: _reducedMotion,
                        activeThumbColor: const Color(0xFF0088FF),
                        onChanged: _toggleReducedMotion,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.school_rounded, color: Color(0xFF00B074)),
                        title: const Text('Replay Toddler Tutorial', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Watch the 4-step demonstration guide again', style: TextStyle(fontSize: 12.5)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: _replayTutorial,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 4: Sticker Shelf Rewards
                _buildSectionHeader('REWARD STICKER SHELF'),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category Badges Earned:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF455A64)),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: allCategories.map((cat) {
                            final hasSticker = _stickers.contains(cat.id) || (_categoryStars[cat.id] ?? 0) >= 3;
                            return Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: hasSticker ? const Color(0xFFFFF8E1) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: hasSticker ? const Color(0xFFFFD54F) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Opacity(
                                opacity: hasSticker ? 1.0 : 0.35,
                                child: Image.asset(
                                  cat.iconPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section 5: Stars Breakdown & Reset
                _buildSectionHeader('PROGRESS BY CATEGORY'),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...allCategories.map((cat) {
                          final count = _categoryStars[cat.id] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    cat.iconPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cat.id == 'alphabet' ? 'Alphabet' : cat.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF78909C),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
                                  ],
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

                // Section 6: About & Privacy
                _buildSectionHeader('ABOUT & PRIVACY'),
                _buildCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF607D8B)),
                        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: const Text('COPPA compliant • Zero data collection', style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFB0BEC5)),
                        onTap: _showPrivacyPolicy,
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline, color: Color(0xFF607D8B)),
                        title: Text('About Giggle Go!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Text('Version 1.0.0 (Offline Preschool Edition)', style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
