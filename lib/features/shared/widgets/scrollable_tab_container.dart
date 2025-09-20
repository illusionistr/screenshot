import 'package:flutter/material.dart';

/// A unified scrollable container for all editor tabs to prevent overflow issues
/// Provides consistent scrolling behavior across all tabs
class ScrollableTabContainer extends StatelessWidget {
  const ScrollableTabContainer({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(20),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.scrollPadding = const EdgeInsets.only(bottom: 20),
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsets scrollPadding;

  const ScrollableTabContainer.unified({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  })  : padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollPadding = const EdgeInsets.only(bottom: 20);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: scrollPadding,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}

/// A variant that supports fixed content at top and bottom with scrollable middle
class ScrollableTabContainerWithSticky extends StatelessWidget {
  const ScrollableTabContainerWithSticky({
    super.key,
    required this.fixedHeader,
    required this.scrollableContent,
    this.fixedFooter,
    this.padding = const EdgeInsets.all(20),
    this.headerSpacing = 24.0,
    this.footerSpacing = 16.0,
  });

  final Widget? fixedHeader;
  final Widget scrollableContent;
  final Widget? fixedFooter;
  final EdgeInsets padding;
  final double headerSpacing;
  final double footerSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (fixedHeader != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              top: padding.top,
            ),
            child: fixedHeader,
          ),
          SizedBox(height: headerSpacing),
        ],
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom:
                  padding.bottom + (fixedFooter != null ? footerSpacing : 0),
            ),
            child: scrollableContent,
          ),
        ),
        if (fixedFooter != null) ...[
          SizedBox(height: footerSpacing),
          Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
            ),
            child: fixedFooter,
          ),
        ],
      ],
    );
  }
}
