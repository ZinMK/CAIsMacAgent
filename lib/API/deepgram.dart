import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';

/*
This class initializes the Deepgram STT, contains all the main transcription methods. 
*/

class DeepgramTranscriber {
  final String apiKey = "";

  late final Deepgram _deepgram = Deepgram(
    apiKey,
    baseQueryParams: {
      'language': 'en',
      'model': 'nova-2-general',
      'smart_format': true,
      "paragarph": true,
      'encoding': 'linear16',
      'sample_rate': 16000,
      'diarize': true,
      'detect_language': false,
    },
  );

  Future<bool> validateApiKey() async {
    return await _deepgram.isApiKeyValid();
  }

  Stream<DeepgramListenResult> getTranscriptionStream(audioStream) async* {
    final isValid = await validateApiKey();
    if (!isValid) {
      throw Exception('Invalid Deepgram API key.');
    }

    try {
      yield* _deepgram.listen.live(audioStream);
    } catch (e) {
      throw Exception('Error in transcription stream: $e');
    }
  }
}
