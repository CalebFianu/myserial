import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../providers/show_provider.dart';

// ── Force-directed graph node ─────────────────────────────────────────

class _GraphNode {
  _GraphNode({
    required this.id,
    required this.label,
    required this.actorName,
    this.avatarUrl,
    required this.color,
    required this.size,
    required Offset position,
  })  : x = position.dx,
        y = position.dy;

  final int id;
  final String label;
  final String actorName;
  final String? avatarUrl;
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
  static const double _minScale = 0.7;
  static const double _maxScale = 4.0;

  late final AnimationController _ctrl;
  final TransformationController _zoom = TransformationController();

  List<_GraphNode> _nodes = [];
  List<_GraphEdge> _edges = [];
  int? _selectedNodeId;

  bool _initialized = false;
  Size? _canvasSize;
  Size? _builtForSize;
  double _temp = 1.0; // simulation "temperature"; cools to 0 then freezes
  int _frozenTicks = 0;

  static final _factionColors = [
    AppColors.signal,
    AppColors.track,
    AppColors.star,
    AppColors.info,
    const Color(0xFF9775FA),
    const Color(0xFFFF922B),
    const Color(0xFF20C997),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
    _zoom.addListener(_onZoomChanged);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _zoom.removeListener(_onZoomChanged);
    _zoom.dispose();
    super.dispose();
  }

  void _onZoomChanged() => setState(() {});

  // ── Graph setup ────────────────────────────────────────────────────

  void _ensureGraph(List<CastMember> cast, Size size) {
    _canvasSize = size;
    final prev = _builtForSize;
    final unchanged = prev != null &&
        _initialized &&
        (prev.width - size.width).abs() < 1.0 &&
        (prev.height - size.height).abs() < 1.0;
    if (unchanged) return;

    _builtForSize = size;
    _initGraph(cast, size);
    _initialized = true;
    _temp = 1.0;
    _frozenTicks = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _nodes.isNotEmpty && !_ctrl.isAnimating) {
        _ctrl.repeat();
      }
    });
  }

  void _initGraph(List<CastMember> cast, Size size) {
    final count = math.min(cast.length, 12);
    if (count == 0) {
      _nodes = [];
      _edges = [];
      return;
    }

    final rng = math.Random(widget.showId + 42);
    final center = Offset(size.width / 2, size.height / 2);

    // Lead sits at the centre; everyone else fans out on a ring so the
    // layout is balanced before the simulation even runs.
    final hasHub = count > 2;
    final ringCount = hasHub ? count - 1 : count;

    // Ring radius that keeps neighbouring nodes on the circle from touching
    // (chord >= node diameter + gap), capped to the available space.
    const minChord = 56.0 + _nodeGap;
    final chordRadius = ringCount > 1
        ? minChord / (2 * math.sin(math.pi / ringCount))
        : 0.0;
    final maxRadius = math.min(size.width, size.height) / 2 - 56;
    final ringR = math.max(80.0, math.min(chordRadius, maxRadius));
    _nodes = List.generate(count, (i) {
      final cm = cast[i];
      final charName = cm.character.isNotEmpty ? cm.character : cm.name;

      final Offset pos;
      if (hasHub && i == 0) {
        pos = center;
      } else {
        final idx = hasHub ? i - 1 : i;
        final angle = (idx / ringCount) * 2 * math.pi - math.pi / 2;
        final jitter = (rng.nextDouble() - 0.5) * 24;
        pos = center +
            Offset(math.cos(angle) * (ringR + jitter),
                math.sin(angle) * (ringR + jitter));
      }

      return _GraphNode(
        id: i,
        label: charName,
        actorName: cm.name,
        avatarUrl: cm.avatarUrl,
        color: _factionColors[i % _factionColors.length],
        size: i == 0 ? 28 : (i < 3 ? 24 : 20),
        position: pos,
      );
    });

    final edges = <_GraphEdge>[];
    if (count > 1) {
      for (var i = 1; i < math.min(count, 5); i++) {
        edges.add(_GraphEdge(0, i));
      }
      for (var i = 1; i < count - 1; i++) {
        edges.add(_GraphEdge(i, i + 1));
      }
      if (count > 4) edges.add(const _GraphEdge(1, 3));
      if (count > 6) edges.add(const _GraphEdge(2, 5));
    }
    _edges = edges;
  }

  // ── Simulation ─────────────────────────────────────────────────────

  // Minimum clear space between two node centres, beyond their radii, so
  // neither the circles nor their labels collide.
  static const double _nodeGap = 18.0;

  void _tick() {
    final size = _canvasSize;
    if (!mounted || size == null || _nodes.isEmpty) return;

    _simulate(size);

    _temp = math.max(0.0, _temp - 0.012);
    if (_temp == 0.0) {
      _frozenTicks++;
      if ((!_hasOverlap() || _frozenTicks > 120) && _ctrl.isAnimating) {
        _ctrl.stop();
      }
    }

    setState(() {});
  }

  void _simulate(Size size) {
    const repulsion = 2600.0;
    const attraction = 0.05;
    const damping = 0.85;
    const spread = 0.02;
    const idealDist = 108.0;

    for (var i = 0; i < _nodes.length; i++) {
      for (var j = i + 1; j < _nodes.length; j++) {
        final a = _nodes[i];
        final b = _nodes[j];
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, double.infinity);
        final force = repulsion / (dist * dist);
        a.vx += force * dx / dist * spread;
        a.vy += force * dy / dist * spread;
        b.vx -= force * dx / dist * spread;
        b.vy -= force * dy / dist * spread;
      }
    }

    for (final edge in _edges) {
      if (edge.from >= _nodes.length || edge.to >= _nodes.length) continue;
      final a = _nodes[edge.from];
      final b = _nodes[edge.to];
      final dx = b.x - a.x;
      final dy = b.y - a.y;
      final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, double.infinity);
      final force = (dist - idealDist) * attraction;
      a.vx += force * dx / dist;
      a.vy += force * dy / dist;
      b.vx -= force * dx / dist;
      b.vy -= force * dy / dist;
    }

    for (final node in _nodes) {
      node.vx *= damping;
      node.vy *= damping;
      node.x += node.vx * _temp;
      node.y += node.vy * _temp;
    }

    // Hard non-overlap constraint — runs at full strength regardless of
    // temperature so the settled layout never has touching nodes.
    _separate();

    for (final node in _nodes) {
      final marginX = node.size + 8;
      final marginTop = node.size + 8;
      final marginBottom = node.size + 26; // room for the name label
      node.x =
          node.x.clamp(marginX, math.max(marginX, size.width - marginX));
      node.y = node.y
          .clamp(marginTop, math.max(marginTop, size.height - marginBottom));
    }
  }

  void _separate() {
    for (var iter = 0; iter < 4; iter++) {
      var moved = false;
      for (var i = 0; i < _nodes.length; i++) {
        for (var j = i + 1; j < _nodes.length; j++) {
          final a = _nodes[i];
          final b = _nodes[j];
          var dx = b.x - a.x;
          var dy = b.y - a.y;
          var dist = math.sqrt(dx * dx + dy * dy);
          final minDist = a.size + b.size + _nodeGap;
          if (dist >= minDist) continue;

          if (dist < 0.01) {
            // Coincident — nudge apart along a deterministic direction.
            dx = (i - j).toDouble();
            dy = 1.0;
            dist = math.sqrt(dx * dx + dy * dy);
          }

          final push = (minDist - dist) / 2;
          final ox = dx / dist * push;
          final oy = dy / dist * push;
          a.x -= ox;
          a.y -= oy;
          b.x += ox;
          b.y += oy;
          // Bleed off the velocity that drove them together.
          a.vx -= ox * 0.5;
          a.vy -= oy * 0.5;
          b.vx += ox * 0.5;
          b.vy += oy * 0.5;
          moved = true;
        }
      }
      if (!moved) break;
    }
  }

  bool _hasOverlap() {
    for (var i = 0; i < _nodes.length; i++) {
      for (var j = i + 1; j < _nodes.length; j++) {
        final a = _nodes[i];
        final b = _nodes[j];
        final dx = b.x - a.x;
        final dy = b.y - a.y;
        if (math.sqrt(dx * dx + dy * dy) < a.size + b.size + _nodeGap - 1) {
          return true;
        }
      }
    }
    return false;
  }

  // ── Interaction ────────────────────────────────────────────────────

  void _handleTapDown(TapDownDetails d) {
    final pos = d.localPosition;
    int? hit;
    for (var i = 0; i < _nodes.length; i++) {
      final n = _nodes[i];
      final dx = pos.dx - n.x;
      final dy = pos.dy - n.y;
      if (math.sqrt(dx * dx + dy * dy) <= n.size + 10) {
        hit = i;
        break;
      }
    }
    setState(() => _selectedNodeId = hit);
  }

  void _zoomBy(double factor) {
    final size = _canvasSize;
    if (size == null) return;
    final current = _zoom.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(_minScale, _maxScale);
    if (target == current) return;
    final k = target / current;
    final focal = Offset(size.width / 2, size.height / 2);
    final around = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(k, k, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
    _zoom.value = _zoom.value.multiplied(around);
  }

  void _resetZoom() => _zoom.value = Matrix4.identity();

  bool get _isZoomed {
    final t = _zoom.value;
    if ((t.getMaxScaleOnAxis() - 1.0).abs() > 0.01) return true;
    final translation = t.getTranslation();
    return translation.x.abs() > 0.5 || translation.y.abs() > 0.5;
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/show/${widget.showId}');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showAsync = ref.watch(showDetailProvider(widget.showId));
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: showAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (e, _) => Center(
          child: Text('Error loading cast', style: AppTypography.body),
        ),
        data: (show) {
          final selectedNode =
              _selectedNodeId != null && _selectedNodeId! < _nodes.length
                  ? _nodes[_selectedNodeId!]
                  : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  topPad + AppSpacing.sp2,
                  AppSpacing.pageGutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back — full 44px hit target, aligned to the gutter
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _goBack,
                      child: Container(
                        height: AppSpacing.hitMin,
                        padding: const EdgeInsets.only(right: AppSpacing.sp3),
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                size: 20, color: AppColors.fg2),
                            SizedBox(width: 6),
                            Text('Back',
                                style: TextStyle(
                                    color: AppColors.fg2, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text('Who you\'ve met', style: AppTypography.title),
                    const SizedBox(height: AppSpacing.sp1),
                    Text(
                      'Characters introduced so far in ${show.title}',
                      style: AppTypography.caption.copyWith(color: AppColors.fg3),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    const Wrap(
                      spacing: AppSpacing.sp3,
                      runSpacing: AppSpacing.sp2,
                      children: [
                        _LegendDot(color: AppColors.signal, label: 'Lead Cast'),
                        _LegendDot(color: AppColors.track, label: 'Supporting'),
                        _LegendDot(color: AppColors.star, label: 'Recurring'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sp4),

              // ── Graph ───────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    _ensureGraph(show.cast, size);

                    if (_nodes.isEmpty) {
                      return Center(
                        child: Text(
                          'No cast characters available.',
                          style: AppTypography.body
                              .copyWith(color: AppColors.fg2),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRect(
                            child: InteractiveViewer(
                              transformationController: _zoom,
                              minScale: _minScale,
                              maxScale: _maxScale,
                              boundaryMargin: const EdgeInsets.all(96),
                              child: SizedBox(
                                width: size.width,
                                height: size.height,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: _handleTapDown,
                                  child: CustomPaint(
                                    size: size,
                                    painter: _GraphPainter(
                                      nodes: _nodes,
                                      edges: _edges,
                                      selectedId: _selectedNodeId,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: AppSpacing.sp3,
                          bottom: AppSpacing.sp3,
                          child: _ZoomControls(
                            onZoomIn: () => _zoomBy(1.4),
                            onZoomOut: () => _zoomBy(1 / 1.4),
                            onReset: _resetZoom,
                            canReset: _isZoomed,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ── Selected node panel ─────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: selectedNode == null
                    ? const SizedBox(width: double.infinity)
                    : Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(
                          AppSpacing.pageGutter,
                          AppSpacing.sp2,
                          AppSpacing.pageGutter,
                          0,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.sp4),
                        decoration: BoxDecoration(
                          color: AppColors.ink1,
                          borderRadius: AppRadius.cardRR,
                          border: Border.all(
                            color: selectedNode.color.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedNode.color.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: selectedNode.color),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(selectedNode.label),
                                  style: TextStyle(
                                    color: selectedNode.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sp3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedNode.label,
                                    style: AppTypography.heading,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Played by ${selectedNode.actorName}',
                                    style: AppTypography.caption
                                        .copyWith(color: AppColors.fg2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Connected to ${_edges.where((e) => e.from == selectedNode.id || e.to == selectedNode.id).length} characters',
                                    style: AppTypography.micro
                                        .copyWith(color: AppColors.fg3),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  setState(() => _selectedNodeId = null),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.fg3),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Keep the graph + info panel clear of the pinned glass nav pill.
              SizedBox(height: GlassBottomNav.contentBottomInset(context)),
            ],
          );
        },
      ),
    );
  }

  static String _initials(String label) => label
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0] : '')
      .take(2)
      .join();
}

// ── Zoom controls ────────────────────────────────────────────────────

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    required this.canReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final bool canReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink2.withOpacity(0.92),
        borderRadius: AppRadius.controlRR,
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),
          const Divider(height: 1, thickness: 1, color: AppColors.inkLine),
          _ZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut),
          if (canReset) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.inkLine),
            _ZoomButton(
                icon: Icons.center_focus_strong_rounded, onTap: onReset),
          ],
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 20, color: AppColors.fg2),
      ),
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────

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

    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final isSelected = i == selectedId;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = n.color.withOpacity(0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(n.x, n.y), n.size + 10, glowPaint);
      }

      final fillPaint = Paint()
        ..color = n.color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(n.x, n.y), n.size, fillPaint);

      final borderPaint = Paint()
        ..color = n.color
        ..strokeWidth = isSelected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(n.x, n.y), n.size, borderPaint);

      final initials = n.label
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join();
      final tp = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: n.color,
            fontSize: n.size * 0.55,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(n.x - tp.width / 2, n.y - tp.height / 2));

      final nameTp = TextPainter(
        text: TextSpan(
          text: n.label,
          style: const TextStyle(color: AppColors.fg2, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 84);
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
