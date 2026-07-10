import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Cari'),
    (icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded, label: 'Favorit'),
    (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Meal Plan'),
    (icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded, label: 'Belanja'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive ? AppColors.primary : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
