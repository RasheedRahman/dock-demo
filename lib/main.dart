import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, isHovered) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: BoxConstraints(
                  minWidth: isHovered ? 64 : 48,
                  minHeight: isHovered ? 64 : 48,
                ),
                height: isHovered ? 64 : 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(
                    child: Icon(e,
                        color: Colors.white, size: isHovered ? 32 : 24)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the draggable and animated [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  /// The builder takes an item and whether it's hovered as inputs.
  final Widget Function(T, bool) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late List<T> _items = widget.items.toList();

  /// Index of the hovered item.
  int? _hoveredIndex;

  /// Index of the item being dragged.
  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Draggable<T>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(item, true),
            ),
            childWhenDragging: const SizedBox.shrink(),
            onDragStarted: () {
              setState(() {
                _draggedIndex = index;
              });
            },
            onDragCompleted: () {
              setState(() {
                if (_draggedIndex != null) {
                  _items.removeAt(_draggedIndex!);
                  _draggedIndex = null;
                }
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggedIndex = null;
              });
            },
            child: DragTarget<T>(
              onWillAccept: (incoming) {
                setState(() {
                  _hoveredIndex = index;
                });
                return true;
              },
              onAccept: (incoming) {
                setState(() {
                  if (_draggedIndex != null) {
                    _items.removeAt(_draggedIndex!);
                    _items.insert(index, incoming);
                    _draggedIndex = null;
                    _hoveredIndex = null;
                  }
                });
              },
              onLeave: (_) {
                setState(() {
                  _hoveredIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return widget.builder(item, _hoveredIndex == index);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
