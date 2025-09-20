import 'package:flutter/material.dart';

class HorizontalReorderableRow extends StatefulWidget {
  final List<Widget> children;
  final Function(int oldIndex, int newIndex) onReorder;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const HorizontalReorderableRow({
    super.key,
    required this.children,
    required this.onReorder,
    this.spacing = 16.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<HorizontalReorderableRow> createState() => _HorizontalReorderableRowState();
}

class _HorizontalReorderableRowState extends State<HorizontalReorderableRow> {
  int? _dragIndex;
  int? _dropIndex;
  Offset? _dragOffset;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.children.length; i++) ...[
            _buildDraggableItem(i),
            if (i < widget.children.length - 1)
              SizedBox(width: widget.spacing),
          ],
        ],
      ),
    );
  }

  Widget _buildDraggableItem(int index) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: Opacity(
            opacity: 0.8,
            child: widget.children[index],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: widget.children[index],
      ),
      onDragStarted: () {
        setState(() {
          _dragIndex = index;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _dragIndex = null;
          _dropIndex = null;
        });
      },
      child: DragTarget<int>(
        onWillAccept: (data) {
          if (data == null || data == index) return false;
          setState(() {
            _dropIndex = index;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _dropIndex = null;
          });
        },
        onAccept: (draggedIndex) {
          if (draggedIndex != index) {
            widget.onReorder(draggedIndex, index);
          }
          setState(() {
            _dragIndex = null;
            _dropIndex = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: _dropIndex == index && _dragIndex != index
                ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: widget.children[index],
          );
        },
      ),
    );
  }
}