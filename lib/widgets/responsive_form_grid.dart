import 'package:flutter/material.dart';

class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({
    required this.children,
    this.breakpoint = 640,
    this.spacing = 14,
    this.runSpacing = 12,
    super.key,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: runSpacing),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final hasSecond = i + 1 < children.length;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(child: hasSecond ? children[i + 1] : const SizedBox.shrink()),
              ],
            ),
          );
          if (i + 2 < children.length) {
            rows.add(SizedBox(height: runSpacing));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
