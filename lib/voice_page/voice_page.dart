import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({Key? key}) : super(key: key);

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  SpeechToText speechToText = SpeechToText();

  Color back = Colors.white;

  /// checks the state listening or not
  ValueNotifier<bool> isListening = ValueNotifier(false);

  /// transformed text from listened voice
  ValueNotifier<String> recognizedText = ValueNotifier("Say Something");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: back,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: recognizedText,
              builder: (context, voiceText, _) => Text(voiceText),
            ),
            ValueListenableBuilder(
              valueListenable: isListening,
              builder: (context, listening, _) {
                return ValueListenableBuilder(
                  valueListenable: recognizedText,
                  builder: (context, voiceText, child) {
                    return GestureDetector(
                      onTapDown: (x) async {
                        if (!isListening.value) {
                          bool isEnabled = await speechToText.initialize();
                          if (isEnabled) {
                            isListening.value = true;
                            speechToText.listen(
                              onResult: (result) {
                                recognizedText.value =
                                    result.recognizedWords.toLowerCase();

                                /// these if statements are includes some commands when user
                                /// use magic words
                                if (recognizedText.value.contains('sunday')) {
                                  // if user say sunday or sunday is the best day
                                  // then the dialog will open called _notmatch
                                  isListening.value = false;
                                  const _NotMatch().show(context);
                                } else if (recognizedText.value
                                    .contains('saturday')) {
                                  isListening.value = false;
                                  const _OpenSheet().show(context);
                                } else if (recognizedText.value
                                    .contains('mor')) {
                                  isListening.value = false;
                                  back = Colors.purple;
                                } else if (recognizedText.value
                                    .contains('beyaz')) {
                                  isListening.value = false;
                                  back = Colors.white;
                                } else {
                                  Future.delayed(const Duration(seconds: 2))
                                      .whenComplete(() {
                                    recognizedText.value = "Komut Bulunamadı";
                                    isListening.value = false;
                                  });
                                }
                              },
                            );
                          }
                        }
                      },
                      onTapUp: (c) {
                        isListening.value = false;
                        speechToText.stop();
                      },
                      child: AvatarGlow(
                        glowColor: Colors.green,
                        repeat: true,
                        animate: isListening.value,
                        duration: const Duration(seconds: 2),
                        endRadius: 75,
                        showTwoGlows: true,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 35,
                          child: Icon(
                            listening ? Icons.stop : Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _NotMatch extends StatelessWidget {
  const _NotMatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Voice Recognized"),
      content: const Text("Content is succesful"),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.pop(context), child: const Text('Geri'))
      ],
    );
  }
}

extension VoiceDialogExtension on _NotMatch {
  show(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => this,
    );
  }
}

class _OpenSheet extends StatelessWidget {
  const _OpenSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Voice recognized"),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Geri'))
      ],
    );
  }
}

extension VoiceSheetExtension on _OpenSheet {
  show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => this,
    );
  }
}
