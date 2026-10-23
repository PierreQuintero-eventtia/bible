import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';

class SettingsModal extends StatefulWidget {
  final TTSService ttsService;
  const SettingsModal({super.key, required this.ttsService});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  List<Map<String, String>> _voices = [];
  String _selectedVoiceName = '';
  String _selectedVoiceLocale = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  void _loadVoices() async {
    final voices = await widget.ttsService.getSpanishVoices();
    final prefs = await StorageService.loadPreferences();
    setState(() {
      _voices = voices;
      _selectedVoiceName = widget.ttsService.currentVoice?['name'] ?? prefs['voiceName'] ?? '';
      _selectedVoiceLocale = widget.ttsService.currentVoice?['locale'] ?? prefs['voiceLocale'] ?? '';
      _loading = false;
    });
  }

  String _cleanVoiceName(String name, String locale) {
    String cleanLocale = locale.replaceAll('_', '-');
    String suffix = name.contains('#') ? name.split('#').last : name.split('-').last;
    return "Español ($cleanLocale) - Voz $suffix";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_voice, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Text("Configuración de Voz", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const Divider(color: Color(0xFF26262B)),
          const SizedBox(height: 8),
          const Text(
            "Selecciona la voz para la lectura bíblica:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _voices.isEmpty
                    ? const Center(
                        child: Text(
                          "No se encontraron voces adicionales en español en el dispositivo.\nSe usará la voz predeterminada del sistema.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _voices.length,
                        itemBuilder: (ctx, i) {
                          final v = _voices[i];
                          final isSelected = v['name'] == _selectedVoiceName;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF22222A) : const Color(0xFF1A1A1E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF2E2E38)),
                            ),
                            child: ListTile(
                              title: Text(
                                _cleanVoiceName(v['name']!, v['locale']!),
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(v['name']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.volume_up, color: Color(0xFFD4AF37)),
                                tooltip: "Probar voz",
                                onPressed: () {
                                  widget.ttsService.applyVoice(v['name']!, v['locale']!);
                                  widget.ttsService.speakSample("En el principio creó Dios los cielos y la tierra.");
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedVoiceName = v['name']!;
                                  _selectedVoiceLocale = v['locale']!;
                                });
                                widget.ttsService.applyVoice(v['name']!, v['locale']!);
                                StorageService.saveVoice(v['name']!, v['locale']!);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
