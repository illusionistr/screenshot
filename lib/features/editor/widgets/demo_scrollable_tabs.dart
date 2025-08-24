import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/scrollable_tab_container.dart';
// Demo file - no project model needed

/// Demo widget showing the unified scrollable tab container in action
class DemoScrollableTabs extends ConsumerWidget {
  const DemoScrollableTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Tabs Demo'),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Text'),
                Tab(text: 'Layout'),
                Tab(text: 'Background'),
                Tab(text: 'Template'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Text Tab Demo
                  ScrollableTabContainer.unified(
                    children: [
                      const Text(
                        'Text Tab Content',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 100,
                        color: Colors.blue.shade100,
                        child:
                            const Center(child: Text('Text Element Selector')),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        color: Colors.green.shade100,
                        child: const Center(child: Text('Content Editor')),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        color: Colors.yellow.shade100,
                        child: const Center(child: Text('Formatting Panel')),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 100,
                        color: Colors.red.shade100,
                        child: const Center(child: Text('Apply Button')),
                      ),
                    ],
                  ),

                  // Layout Tab Demo
                  ScrollableTabContainerWithSticky(
                    padding: const EdgeInsets.all(20),
                    fixedHeader: Container(
                      height: 80,
                      color: Colors.purple.shade100,
                      child: const Center(
                          child: Text('Fixed Header\n(Layout Controls)')),
                    ),
                    scrollableContent: Column(
                      children: List.generate(
                        20,
                        (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.teal.shade100,
                          child:
                              Center(child: Text('Layout Item ${index + 1}')),
                        ),
                      ),
                    ),
                    fixedFooter: Container(
                      height: 60,
                      color: Colors.orange.shade100,
                      child: const Center(child: Text('Apply Buttons')),
                    ),
                  ),

                  // Background Tab Demo
                  ScrollableTabContainerWithSticky(
                    padding: const EdgeInsets.all(20),
                    fixedHeader: Container(
                      height: 50,
                      color: Colors.indigo.shade100,
                      child: const Center(child: Text('Background Tabs')),
                    ),
                    scrollableContent: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          height: 400,
                          color: Colors.pink.shade100,
                          child: const Center(
                              child: Text(
                                  'Background Content\n(Solid/Gradient/Image)')),
                        ),
                      ],
                    ),
                    fixedFooter: Container(
                      height: 50,
                      color: Colors.brown.shade100,
                      child: const Center(child: Text('Apply to All')),
                    ),
                  ),

                  // Template Tab Demo
                  ScrollableTabContainer.unified(
                    children: [
                      const SizedBox(height: 100),
                      Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text(
                            'Template Management\nComing Soon...',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
