import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../providers/show_provider.dart';

// ── Force-directed graph node ─────────────────────────────────────────────────

class _GraphNode {
  _GraphNode({
    required this.id,
    required this.label,
    required this.color,
    required this.size,
    required Offset position,
  })  : x = position.dx,
        y = position.dy;

  final int id;
  final String label;
  final Color color;
  final double size;
  double x;
  double y;
  double vx = 0;
  double vy = 0;
}

class _GraphEdge {
  const _GraphEdge(this.from, this.to);
  final int from;
  final int to;
}

class CastGraphScreen extends ConsumerStatefulWidget {
  const CastGraphScreen({super.key, required this.showId});
  final int showId;

  @override
  ConsumerState<CastGraphScreen> createState() => _CastGraphScreenState();
}

class _CastGraphScreenState extends ConsumerState<CastGraphScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_GraphNode> _nodes;
  late List<_GraphEdge> _edges;
  int? _selectedNodeId;

  static final _factionColors = [
    AppColors.signal,
    AppColors.track,
    AppColors.star,
    AppColors.info,
    const Color(0xFF9775FA),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    _initGraph();
  }

  void _initGraph() {
    final rng = math.Random(42);
    final screenW = 400.0;
    final screenH = 350.0;

    _nodes = List.generate(8, (i) {
      return _GraphNode(
        id: i,
        label: [
          'Mark S.',
          'Helly R.',
          'Dylan G.',
          'Irving B.',
          'Milchick',
          'Cobel',
          'Reghabi',
          'Devon',
        ][i],
        color: _factionColors[i % _factionColors.length],
        size: i == 0 ? 28 : 20,
        position: Offset(
          80 + rng.nextDouble() * (screenW - 160),
          60 + rng.nextDouble() * (screenH - 120),
        ),
      );
    });

    _edges = const [
      _GraphEdge(0, 1),
      _GraphEdge(0, 2),
      _GraphEdge(0, 3),
      _GraphEdge(1, 4),
      _GraphEdge(2, 4),
      _GraphEdge(3, 5),
      _GraphEdge(0, 6),
      _GraphEdge(0, 7),
      _GraphEdge(4, 5),
    ];
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _simulate(Size size) {
    const alpha = 0.02;
    const repulsion = 1800.0;
    const attraction = 0.05;
    const damping = 0.85;

    for (var i = 0; i < _nodes.length; i++) {
      for (var j = i + 1; j < _nodes.length; j++) {
        final a = _nodes[i];
        final b = _nodes[j];
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, double.infinity);
        final force = repulsion / (dist * dist);
        a.vx += force * dx / dist * alpha;
        a.vy += force * dy / dist * alpha;
        b.vx -= force * dx / dist * alpha;
        b.vy -= force * dy / dist * alpha;
      }
    }

    for (final edge in _edges) {
      final a = _nodes[edge.from];
      final b = _nodes[edge.to];
      final dx = b.x - a.x;
      final dy = b.y - a.y;
      final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, double.infinity);
      final idealDist = 90.0;
      final force = (dist - idealDist) * attraction;
      a.vx += force * dx / dist;
      a.vy += force * dy / dist;
      b.vx -= force * dx / dist;
      b.vy -= force * dy / dist;
    }

    for (final node in _nodes) {
      node.vx *= damping;
      node.vy *= damping;
      node.x = (node.x + node.vx).clamp(node.size, size.width - node.size);
      node.y = (node.y + node.vy).clamp(node.size, size.height - node.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showAsync = ref.watch(showDetailProvider(widget.showId));
    final topPad = MediaQuery.paddingOf(context).top;
    final selectedNode =
        _selectedNodeId != null ? _nodes[_selectedNodeId!] : null;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              topPad + AppSpacing.sp4,
              AppSpacing.pageGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.fg3),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(color: AppColors.fg3, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sp3),
                Text('Who you\'ve met', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sp3),
                // Legend
                Wrap(
                  spacing: AppSpacing.sp3,
                  runSpacing: AppSpacing.sp2,
                  children: [
                    _LegendDot(color: AppColors.signal, label: 'MDR Team'),
                    _LegendDot(color: AppColors.track, label: 'Management'),
                    _LegendDot(color: AppColors.star, label: 'Outside'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // Graph
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    _simulate(size);
                    return GestureDetector(
                      onTapDown: (d) {
                        final pos = d.localPosition;
                        int? hit;
                        for (var i = 0; i < _nodes.length; i++) {
                          final n = _nodes[i];
                          final dx = pos.dx - n.x;
                          final dy = pos.dy - n.y;
                          if (math.sqrt(dx * dx + dy * dy) <= n.size + 8) {
                            hit = i;
                            break;
                          }
                        }
                        setState(() => _selectedNodeId = hit);
                      },
                      child: CustomPaint(
                        size: size,
                        painter: _GraphPainter(
                          nodes: _nodes,
                          edges: _edges,
                          selectedId: _selectedNodeId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Selected node panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: selectedNode != null ? 100 : 0,
            child: selectedNode != null
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.pageGutter),
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: AppColors.ink1,
                      borderRadius: AppRadius.cardRR,
                      border: Border.all(color: selectedNode.color.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedNode.label, style: AppTypography.heading),
                        const SizedBox(height: 4),
                        Text(
                          'Connected to ${_edges.where((e) => e.from == selectedNode.id || e.to == selectedNode.id).length} characters',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.sp4),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  const _GraphPainter({
    required this.nodes,
    required this.edges,
    this.selectedId,
  });

  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final int? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    final edgePaint = Paint()
      ..color = AppColors.inkLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      if (edge.from >= nodes.length || edge.to >= nodes.length) continue;
      final a = nodes[edge.from];
      final b = nodes[edge.to];
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), edgePaint);
    }

    // Draw nodes
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final isSelected = i == selectedId;

      // Outer glow for selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = n.color.withOpacity(0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(n.x, n.y), n.size + 10, glowPaint);
      }

      // Node fill
      final fillPaint = Paint()
        ..color = n.color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(n.x, n.y), n.size, fillPaint);

      // Node border
      final borderPaint = Paint()
        ..color = n.color
        ..strokeWidth = isSelected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(n.x, n.y), n.size, borderPaint);

      // Label
      final initials = n.label.split(' ').map((w) => w[0]).take(2).join();
      final tp = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: n.color,
            fontSize: n.size * 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(n.x - tp.width / 2, n.y - tp.height / 2),
      );

      // Name label below node
      final nameTp = TextPainter(
        text: TextSpan(
          text: n.label,
          style: const TextStyle(
            color: AppColors.fg2,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);
      nameTp.paint(
        canvas,
        Offset(n.x - nameTp.width / 2, n.y + n.size + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) => true;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.micro),
      ],
    );
  }
}
