import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'dart:convert';
import 'dart:typed_data';

class DeepgramVoiceAgent extends StatefulWidget {
  final String apiKey;

  const DeepgramVoiceAgent({Key? key, required this.apiKey}) : super(key: key);

  @override
  _DeepgramVoiceAgentState createState() => _DeepgramVoiceAgentState();
}

class _DeepgramVoiceAgentState extends State<DeepgramVoiceAgent> {
  WebSocketChannel? _channel;
  final _audioPlayer = AudioPlayer();

  final _audioRecorder = AudioRecorder();
  bool _isConnected = false;
  bool _isListening = false;
  String _latestMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _connectToDeepgram();
  }

  Future<void> initPlayer() async {
    try {} catch (e) {
      print(e);
    }
  }

  Future<void> _initializeRecorder() async {
    // Check and request permissions
    if (await _audioRecorder.hasPermission()) {
      // Configure the recorder
      await _audioRecorder.isEncoderSupported(AudioEncoder.pcm16bits);
    }
  }

  Future<void> _connectToDeepgram() async {
    final wsUrl = Uri.parse('wss://agent.deepgram.com/agent');

    _channel = WebSocketChannel.connect(
      wsUrl,
      protocols: ['token', widget.apiKey],
    );

    _sendConfiguration();

    _channel!.stream.listen(
      (message) => _handleServerMessage(message),
      onError: (error) {
        print('WebSocket error: $error');
        setState(() => _isConnected = false);
      },
      onDone: () {
        setState(() => _isConnected = false);
        print('WebSocket connection closed');
      },
    );

    setState(() => _isConnected = true);
  }

  void _sendConfiguration() {
    final configuration = {
      "type": "SettingsConfiguration",
      "audio": {
        "input": {"encoding": "linear16", "sample_rate": 16000},
        "output": {
          "encoding": 'linear16',
          "sample_rate": 24000,
          "container": "wav",
        },
      },
      "agent": {
        "listen": {"model": "nova-2"},
        "think": {
          "provider": {
            "type": "open_ai",
            // ... additional provider options available
          },
          "model": "gpt-4o-mini",
          // ... additional think options including instructions and functions available
        },
        "speak": {"model": "aura-luna-en"},
      },
      // ... additional top-level options including context available
    };

    _channel?.sink.add(jsonEncode(configuration));
  }

  void _handleServerMessage(dynamic message) {
    print("yep" + message.toString());
    if (message is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        switch (data['type']) {
          case 'Speech':
            print('speech');
            _playAudioData(data['audio']);
            break;
          case 'Transcript':
            setState(() => _latestMessage = data['text']);
            break;
          case 'Error':
            print('Error from server: ${data['message']}');
            setState(() => _latestMessage = 'Error: ${data['message']}');
            break;
          case 'AgentResponse':
            setState(() => _latestMessage = data['response']);
            break;
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    } else if (message is Uint8List) {
      _playAudioData(message);
    }
  }

  void _playAudioData(Uint8List audioData) async {
    try {
      // Assuming audioData is raw PCM, wrap it in a WAV header
      Uint8List wavData = _convertLinear16ToWav(audioData, 24000, 1);

      // Create a data URI with the WAV data
      final uri = Uri.dataFromBytes(wavData, mimeType: 'audio/wav');

      // Set the audio source to the player
      await _audioPlayer.setUrl(uri.toString());
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Helper function to add a WAV header to raw PCM data
  Uint8List _convertLinear16ToWav(
    Uint8List audioData,
    int sampleRate,
    int channels,
  ) {
    final headerSize = 44;
    final byteRate = sampleRate * channels * 2; // 2 bytes per sample for PCM16
    final fileSize = audioData.length + headerSize;

    // Create WAV header
    final header =
        ByteData(headerSize)
          ..setUint32(0, 0x46464952, Endian.little) // "RIFF"
          ..setUint32(4, fileSize - 8, Endian.little)
          ..setUint32(8, 0x45564157, Endian.little) // "WAVE"
          ..setUint32(12, 0x20746d66, Endian.little) // "fmt "
          ..setUint32(16, 16, Endian.little) // Subchunk1Size (PCM)
          ..setUint16(20, 1, Endian.little) // AudioFormat (PCM)
          ..setUint16(22, channels, Endian.little) // NumChannels
          ..setUint32(24, sampleRate, Endian.little) // SampleRate
          ..setUint32(28, byteRate, Endian.little) // ByteRate
          ..setUint16(32, channels * 2, Endian.little) // BlockAlign
          ..setUint16(34, 16, Endian.little) // BitsPerSample
          ..setUint32(36, 0x61746164, Endian.little) // "data"
          ..setUint32(40, audioData.length, Endian.little); // Subchunk2Size

    // Combine the header and PCM data
    return Uint8List.fromList(header.buffer.asUint8List() + audioData);
  }

  // Future<void> _playAudioData(
  //   Uint8List audioData,
  //   int sampleRate,
  //   int channels,
  // ) async {
  //   try {
  //     // Add WAV header to Linear16 data
  //     Uint8List wavData = _convertLinear16ToWav(
  //       audioData,
  //       sampleRate,
  //       channels,
  //     );

  //     // Convert to a data URI
  //     final uri = Uri.dataFromBytes(wavData, mimeType: 'audio/linear16');

  //     // Play the audio
  //     await _audioPlayer.setUrl(uri.toString());
  //     await _audioPlayer.play();
  //   } catch (e) {
  //     print('Error playing audio data: $e');
  //   }
  // }

  // Uint8List _convertLinear16ToWav(
  //   Uint8List audioData,
  //   int sampleRate,
  //   int channels,
  // ) {
  //   // WAV header size is 44 bytes
  //   final headerSize = 44;
  //   final byteRate =
  //       sampleRate * channels * 2; // 2 bytes per sample for Linear16
  //   final fileSize = audioData.length + headerSize;

  //   // Create the header
  //   final header =
  //       ByteData(headerSize)
  //         ..setUint32(0, 0x46464952, Endian.little) // "RIFF" in ASCII
  //         ..setUint32(4, fileSize - 8, Endian.little)
  //         ..setUint32(8, 0x45564157, Endian.little) // "WAVE" in ASCII
  //         ..setUint32(12, 0x20746d66, Endian.little) // "fmt " in ASCII
  //         ..setUint32(16, 16, Endian.little) // Subchunk1Size (16 for PCM)
  //         ..setUint16(20, 1, Endian.little) // AudioFormat (1 for PCM)
  //         ..setUint16(22, channels, Endian.little) // NumChannels
  //         ..setUint32(24, sampleRate, Endian.little) // SampleRate
  //         ..setUint32(28, byteRate, Endian.little) // ByteRate
  //         ..setUint16(32, channels * 2, Endian.little) // BlockAlign
  //         ..setUint16(34, 16, Endian.little) // BitsPerSample
  //         ..setUint32(36, 0x61746164, Endian.little) // "data" in ASCII
  //         ..setUint32(40, audioData.length, Endian.little); // Subchunk2Size

  //   // Combine the header and audio data
  //   return Uint8List.fromList(header.buffer.asUint8List() + audioData);
  // }

  Future<void> _startListening() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Configure audio recording
        final stream = await _audioRecorder.startStream(
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        // Start streaming audio data
        // _audioRecorder
        //     .onAmplitudeChanged(const Duration(milliseconds: 100))
        //     .listen((amp) async {
        //       if (_channel != null && _isListening) {
        //         // Get the raw audio data
        //         final buffer = await _audioRecorder.convertAmplitudeToBytes(
        //           amp,
        //         );

        //         if (buffer != null) {
        //           // Send the audio data through WebSocket
        //           _channel!.sink.add(buffer);
        //         }
        //       }
        //     });

        stream.listen((data) {
          if (_channel != null && _isListening) {
            _channel!.sink.add(data); // data is already Uint8List
          }
        });
        setState(() => _isListening = true);
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    try {
      await _audioRecorder.stop();
      setState(() => _isListening = false);
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _toggleListening() {
    if (!_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deepgram Voice Agent'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _latestMessage.isEmpty
                      ? 'Press the button and start speaking'
                      : _latestMessage,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: FloatingActionButton(
              onPressed: _isConnected ? _toggleListening : null,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              backgroundColor:
                  _isConnected
                      ? (_isListening ? Colors.red : null)
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
