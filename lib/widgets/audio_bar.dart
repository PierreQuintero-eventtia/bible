import 'package:flutter/material.dart';
class AudioBar extends StatelessWidget {
  final bool isPlaying;
  final double currentRate;
  final VoidCallback onPlayPause, onStop, onNext, onPrev, onSpeedCycle;
  const AudioBar({super.key, required this.isPlaying, required this.currentRate, required this.onPlayPause, required this.onStop, required this.onNext, required this.onPrev, required this.onSpeedCycle});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      height: 64,
      decoration: BoxDecoration(color: const Color(0xFF1E1E24), borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFF2E2E38))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(onPressed: onSpeedCycle, child: Text(currentRate <= 0.4 ? "0.75x" : currentRate <= 0.5 ? "1.0x" : "1.25x", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: onPrev),
          FloatingActionButton.small(backgroundColor: const Color(0xFFD4AF37), onPressed: onPlayPause, child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black)),
          IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: onNext),
          IconButton(icon: const Icon(Icons.stop, color: Colors.redAccent), onPressed: onStop),
        ],
      ),
    );
  }
}
