import 'package:flutter/material.dart';

class TankToggle extends StatelessWidget {
  const TankToggle({
    required this.isOn,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.busy = false,
  });

  final bool isOn;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canInteract = enabled && !busy;
    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x190F172A),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleOption(
                    icon: Icons.power_settings_new,
                    title: 'Pump off',
                    subtitle: 'Stops water flow',
                    selected: !isOn,
                    onTap: canInteract && isOn ? () => onChanged(false) : null,
                    theme: theme,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ToggleOption(
                    icon: Icons.bolt,
                    title: 'Pump on',
                    subtitle: 'Starts pumping now',
                    selected: isOn,
                    onTap: canInteract && !isOn ? () => onChanged(true) : null,
                    theme: theme,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!enabled)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        if (busy)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.75),
            ),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.theme,
    required this.borderRadius,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final ThemeData theme;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? theme.colorScheme.primary : const Color(0xFF334155);
    final subtitleColor = selected ? theme.colorScheme.primary.withOpacity(0.75) : const Color(0xFF64748B);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: selected ? Colors.white : Colors.white.withOpacity(0.35),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x1A1E3A8A),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : const Color(0xFFE2E8F0),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    icon,
                    color: selected ? theme.colorScheme.primary : const Color(0xFF64748B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
