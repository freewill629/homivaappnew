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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final outerRadius = BorderRadius.circular(22);
        return Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: outerRadius,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ToggleOption(
                            icon: Icons.power_settings_new,
                            title: 'Pump off',
                            subtitle: 'Stops water flow',
                            selected: !isOn,
                            onTap: canInteract && isOn ? () => onChanged(false) : null,
                            theme: theme,
                            borderRadius: BorderRadius.circular(16),
                            dense: true,
                          ),
                          const SizedBox(height: 4),
                          _ToggleOption(
                            icon: Icons.bolt,
                            title: 'Pump on',
                            subtitle: 'Starts pumping now',
                            selected: isOn,
                            onTap: canInteract && !isOn ? () => onChanged(true) : null,
                            theme: theme,
                            borderRadius: BorderRadius.circular(16),
                            dense: true,
                          ),
                        ],
                      )
                    : Row(
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
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: _ToggleOption(
                              icon: Icons.bolt,
                              title: 'Pump on',
                              subtitle: 'Starts pumping now',
                              selected: isOn,
                              onTap: canInteract && !isOn ? () => onChanged(true) : null,
                              theme: theme,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomRight: Radius.circular(18),
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
                  borderRadius: outerRadius,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            if (busy)
              Container(
                decoration: BoxDecoration(
                  borderRadius: outerRadius,
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
      },
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
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final ThemeData theme;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? theme.colorScheme.primary : const Color(0xFF334155);
    final subtitleColor = selected ? theme.colorScheme.primary.withOpacity(0.75) : const Color(0xFF64748B);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: selected ? Colors.white : const Color(0xFFF1F5F9),
        border: Border.all(
          color: selected ? theme.colorScheme.primary.withOpacity(0.24) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 16 : 20,
              vertical: dense ? 14 : 16,
            ),
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
                  padding: EdgeInsets.all(dense ? 8 : 10),
                  child: Icon(
                    icon,
                    color: selected ? theme.colorScheme.primary : const Color(0xFF64748B),
                    size: dense ? 18 : 20,
                  ),
                ),
                SizedBox(width: dense ? 12 : 16),
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
