import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shop / Wardrobe Screen matching Stitch Screen 4.
///
/// Features:
/// - Currency Header Strip: "Wardrobe" with Gold Coins and Crystals balance.
/// - Segmented Physical Tabs: "Balls", "Tubes", "Backdrops".
/// - Hero Interactive Preview Stage: Equipped "Cosmic Glow" set with floating preview ball and real skeuomorphic glass tube.
/// - Available Sets list:
///   - "Cosmic Glow" (Legendary, Equipped)
///   - "Juicy Fruits" (Rare, Owned, Equip button)
///   - "Emoji Fun" (Common, 1,100 Coins unlock)
///   - "Elemental Orbs" (Epic, 2,100 Coins unlock)
///   - "Galactic Planets" (Epic, Level 50 Locked)
///   - "Candy Bonbon" (VIP Pass required)
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedTabIndex = 0;
  String _equippedSet = 'Cosmic Glow';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              color: AppTheme.surface.withAlpha(220),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop()) ...[
                        GestureDetector(
                          key: const Key('shop_back_button'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceContainerLow,
                              border: Border.all(
                                color: AppTheme.primary.withAlpha(80),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.primary,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryContainer,
                        ),
                        child: const Icon(
                          Icons.bubble_chart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ball Sort',
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Shop',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _CurrencyChip(
                        icon: Icons.monetization_on,
                        iconColor: AppTheme.secondary,
                        text: '2,450',
                      ),
                      const SizedBox(width: 6),
                      _CurrencyChip(
                        icon: Icons.diamond,
                        iconColor: AppTheme.tertiary,
                        text: '35',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Tabs: Balls, Tubes, Backdrops
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Row(
                        children: [
                          _SegmentTab(
                            title: 'Balls',
                            icon: Icons.bubble_chart,
                            isSelected: _selectedTabIndex == 0,
                            onTap: () => setState(() => _selectedTabIndex = 0),
                          ),
                          _SegmentTab(
                            title: 'Tubes',
                            icon: Icons.science,
                            isSelected: _selectedTabIndex == 1,
                            onTap: () => setState(() => _selectedTabIndex = 1),
                          ),
                          _SegmentTab(
                            title: 'Backdrops',
                            icon: Icons.wallpaper,
                            isSelected: _selectedTabIndex == 2,
                            onTap: () => setState(() => _selectedTabIndex = 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hero Equipped Stage
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: AppTheme.secondary,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'CURRENTLY EQUIPPED',
                                      style: TextStyle(
                                        color: AppTheme.secondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _equippedSet,
                                  style: const TextStyle(
                                    color: AppTheme.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Neon refractive core with spectral stardust aura',
                                  style: TextStyle(
                                    color: AppTheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.surfaceContainerHigh,
                                    foregroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  icon: const Icon(Icons.touch_app, size: 16),
                                  label: const Text(
                                    'Tap to Bounce',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Mini Skeuomorphic Tube Preview
                          _MiniGlassTubePreview(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'AVAILABLE SETS',
                      style: TextStyle(
                        color: AppTheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Set 1: Cosmic Glow (Equipped)
                    _SkinCard(
                      title: 'Cosmic Glow',
                      rarity: 'Legendary',
                      rarityColor: AppTheme.primary,
                      description: 'Glowing prismatic nebulae',
                      ballColors: const [
                        Color(0xFFACEDFF),
                        Color(0xFFD2BBFF),
                        Color(0xFFF43F5E),
                        Color(0xFFFFB95F),
                      ],
                      isEquipped: _equippedSet == 'Cosmic Glow',
                      buttonLabel: 'EQUIPPED',
                      onAction: () =>
                          setState(() => _equippedSet = 'Cosmic Glow'),
                    ),

                    const SizedBox(height: 12),

                    // Set 2: Juicy Fruits (Owned)
                    _SkinCard(
                      title: 'Juicy Fruits',
                      rarity: 'Rare',
                      rarityColor: AppTheme.secondary,
                      description: 'Watermelon, Orange, Blueberry & Lime',
                      ballColors: const [
                        Color(0xFFEF4444),
                        Color(0xFFF97316),
                        Color(0xFF3B82F6),
                        Color(0xFF10B981),
                      ],
                      isEquipped: _equippedSet == 'Juicy Fruits',
                      buttonLabel: _equippedSet == 'Juicy Fruits'
                          ? 'EQUIPPED'
                          : 'EQUIP SET',
                      onAction: () =>
                          setState(() => _equippedSet = 'Juicy Fruits'),
                    ),

                    const SizedBox(height: 12),

                    // Set 3: Emoji Fun (Unlockable)
                    _SkinCard(
                      title: 'Emoji Fun',
                      rarity: 'Common',
                      rarityColor: AppTheme.onSurfaceVariant,
                      description: 'Joy, Cool Shades, Hearts & Shocked',
                      ballColors: const [
                        Color(0xFFFACC15),
                        Color(0xFFFB923C),
                        Color(0xFFF43F5E),
                        Color(0xFF38BDF8),
                      ],
                      buttonLabel: 'UNLOCK FOR 1,100',
                      buttonIcon: Icons.monetization_on,
                      isUnlockable: true,
                      onAction: () {},
                    ),

                    const SizedBox(height: 12),

                    // Set 4: Elemental Orbs
                    _SkinCard(
                      title: 'Elemental Orbs',
                      rarity: 'Epic',
                      rarityColor: AppTheme.tertiary,
                      description: 'Fire, Water, Lightning & Nether Void',
                      ballColors: const [
                        Color(0xFFDC2626),
                        Color(0xFF0284C7),
                        Color(0xFFEAB308),
                        Color(0xFF7E22CE),
                      ],
                      buttonLabel: 'UNLOCK FOR 2,100',
                      buttonIcon: Icons.monetization_on,
                      isUnlockable: true,
                      onAction: () {},
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _CurrencyChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryContainer.withAlpha(120),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.onPrimaryContainer
                    : AppTheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.onPrimaryContainer
                      : AppTheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGlassTubePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
      ),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: const [
          _MiniOrb(color: Color(0xFFFFB95F)),
          SizedBox(height: 3),
          _MiniOrb(color: Color(0xFFF43F5E)),
          SizedBox(height: 3),
          _MiniOrb(color: Color(0xFFACEDFF)),
        ],
      ),
    );
  }
}

class _MiniOrb extends StatelessWidget {
  final Color color;

  const _MiniOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [Colors.white, color],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  final String title;
  final String rarity;
  final Color rarityColor;
  final String description;
  final List<Color> ballColors;
  final bool isEquipped;
  final bool isUnlockable;
  final String buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback onAction;

  const _SkinCard({
    required this.title,
    required this.rarity,
    required this.rarityColor,
    required this.description,
    required this.ballColors,
    this.isEquipped = false,
    this.isUnlockable = false,
    required this.buttonLabel,
    this.buttonIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha(200),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isEquipped
              ? AppTheme.primaryContainer.withAlpha(160)
              : Colors.white.withAlpha(15),
          width: isEquipped ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: rarityColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rarity,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isEquipped)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primary,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          // Ball Previews
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ballColors.map((color) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        colors: [Colors.white.withAlpha(200), color],
                      ),
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped
                      ? AppTheme.surfaceContainerHigh
                      : (isUnlockable
                            ? AppTheme.secondaryContainer
                            : AppTheme.primaryContainer),
                  foregroundColor: isEquipped
                      ? AppTheme.onSurfaceVariant
                      : (isUnlockable
                            ? AppTheme.onSecondaryContainer
                            : AppTheme.onPrimaryContainer),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (buttonIcon != null) ...[
                      Icon(buttonIcon, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
