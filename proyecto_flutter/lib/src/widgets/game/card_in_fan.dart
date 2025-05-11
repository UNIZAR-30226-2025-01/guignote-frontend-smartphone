import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/game/game_screen.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';

class CardInFan extends StatefulWidget {
  final String card;
  final String deck;
  final double width;
  final double angle;
  final double dx;
  final bool selected;
  final VoidCallback onTap;

  const CardInFan({
    super.key,
    required this.card,
    required this.deck,
    required this.width,
    required this.angle,
    required this.dx,
    required this.selected,
    required this.onTap,
  });

  @override
  State<CardInFan> createState() => _CardInFanState();
}

class _CardInFanState extends State<CardInFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant CardInFan old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      if (widget.selected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder:
          (_, child) => Transform.translate(
            offset: Offset(widget.dx, widget.selected ? -30 : 0),
            child: Transform.rotate(
              angle: widget.angle,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow:
                        widget.selected
                            ? [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                            : [],
                  ),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: GameCard(card: widget.card, deck: widget.deck, width: widget.width),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
