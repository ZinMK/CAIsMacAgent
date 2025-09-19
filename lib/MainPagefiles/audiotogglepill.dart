import 'package:aiagentchatbot/API/deepgram.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'dart:async';

class AudioTogglePill extends StatefulWidget {
  final TextEditingController onTranscriptionComplete;

  const AudioTogglePill({super.key, required this.onTranscriptionComplete});

  @override
  State<StatefulWidget> createState() => _AudioTogglePillState();
}

class _AudioTogglePillState extends State<AudioTogglePill> {
  static bool isRecording = false;
  bool isPlaying = false;
  final record = AudioRecorder();
  String? audioPath;
  TextEditingController transcript = TextEditingController();
  Timer? _timer;
  int _recordingDuration = 0;
  String _currentTranscript = '';
  bool showSendButton = false;
  StreamSubscription? _transcriptionSubscription;
  final DeepgramTranscriber _transcriber = DeepgramTranscriber();
  Map<int, String> _speakerTranscriptions =
      {}; // Track transcriptions per speaker

  final double totalWidth = 200.0; // Total combined width
  final double buttonHeight = 40.0;

  // Calculate dynamic widths
  double get recordButtonWidth =>
      isRecording ? totalWidth * 0.75 : totalWidth * 0.5;
  double get playButtonWidth =>
      totalWidth - recordButtonWidth - 8.0; // 8.0 is the gap

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          //  padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            //  color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRecordButton(),
              SizedBox(width: 5),
              _buildPlayButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: recordButtonWidth,
      height: buttonHeight,
      child: Material(
        color:
            isRecording
                ? const Color.fromARGB(255, 0, 110, 255)
                : const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _handleRecordButton,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.black : Colors.white,
                  size: 20,
                ),
                if (isRecording) ...[
                  SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: playButtonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _handleRecordButton() async {
    try {
      if (!isRecording) {
        if (await record.hasPermission()) {
          // Start recording with stream
          final stream = await record.startStream(
            RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000,
              numChannels: 1,
            ),
          );

          setState(() {
            isRecording = true;
            _currentTranscript = '';
            showSendButton = false;
          });

          _startTimer();

          try {
            final transcriptionStream = _transcriber.getTranscriptionStream(
              stream,
            );

            transcriptionStream.listen(
              (result) {
                if (result.map.containsKey('channel') &&
                    result.map['channel']['alternatives'] != null &&
                    result.map['channel']['alternatives'][0]['words'] != null) {
                  setState(() {
                    final words =
                        result.map['channel']['alternatives'][0]['words']
                            as List;

                    for (var word in words) {
                      int speaker = word['speaker'] as int;
                      String punctuatedWord = word['punctuated_word'] as String;

                      _speakerTranscriptions[speaker] ??= '';

                      if (_speakerTranscriptions[speaker]!.isNotEmpty) {
                        _speakerTranscriptions[speaker] =
                            '${_speakerTranscriptions[speaker]} $punctuatedWord';
                      } else {
                        _speakerTranscriptions[speaker] = punctuatedWord;
                      }
                    }

                    _currentTranscript = _speakerTranscriptions.entries
                        .map(
                          (entry) => 'Speaker ${entry.key + 1}: ${entry.value}',
                        )
                        .join('\n\n');

                    transcript.text = _currentTranscript;
                    widget.onTranscriptionComplete.text = transcript.text;
                    print(widget.onTranscriptionComplete.text);
                    showSendButton = _currentTranscript.trim().isNotEmpty;
                  });
                }
              },
              onError: (error) {
                print('Transcription error: $error');
              },
              onDone: () {
                print('Transcription stream closed.');
              },
            );
          } catch (e) {
            print('Error during transcription: $e');
          }
          // try {
          //   final transcriptionStream = _transcriber.getTranscriptionStream(
          //     stream,
          //   );

          //   _transcriptionSubscription = transcriptionStream.listen(
          //     (result) {
          //       setState(() {

          //         _currentTranscript =
          //             _currentTranscript + " " + result.transcript.toString()!;
          //         transcript.text = _currentTranscript.toString();
          //       });
          //     },
          //     onError: (error) {
          //       print('Transcription error: $error');
          //     },
          //     onDone: () {
          //       print('Transcription stream closed.');
          //     },
          //   );
          // } catch (e) {
          //   print('Error during transcription: $e');
          // }
        }
      } else {
        await record.stop();
        _transcriptionSubscription?.cancel();

        setState(() {
          isRecording = false;
          showSendButton = true;
        });

        _stopTimer();
      }
    } catch (e) {
      print('Error during recording: $e');
      setState(() {
        isRecording = false;
      });
      _stopTimer();
    }
  }

  @override
  void dispose() {
    transcript.dispose();
    _stopTimer();
    _transcriptionSubscription?.cancel();
    _speakerTranscriptions.clear();
    record.dispose();
    super.dispose();
  }
}
