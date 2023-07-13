import 'dart:convert';

import 'package:http/http.dart' as http;

import '../secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String propmt) async {
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            'messages': [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an AI picture, image, art or something similar? $propmt . '
                        'Simply answer yes or no.'
              }
            ],
          },
        ),
      );
      print(result.body);
      if (result.statusCode == 200) {
        print('Success');
        // since method of body is string, we should write the response body in jsonDecode method.(we cant store response body directly as it is string)
        String content =
            jsonDecode(result.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final response = await dallEAPI(propmt);

            return response;

          default:
            final response = await chatGPTAPI(propmt);

            return response;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String propmt) async {
    messages.add({
      'role': 'user',
      'content': propmt,
    });
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode(
          {"model": "gpt-3.5-turbo", 'messages': messages},
        ),
      );
      if (result.statusCode == 200) {
        print('Success');
        // since method of body is string, we should write the response body in jsonDecode method.(we cant store response body directly as it is string)
        String content =
            jsonDecode(result.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String propmt) async {
    messages.add({
      'role': 'user',
      'content': propmt,
    });
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode(
          {
            "prompt": propmt,
            'n': 1,
          },
        ),
      );
      if (result.statusCode == 200) {
        print('Success');
        // since method of body is string, we should write the response body in jsonDecode method.(we cant store response body directly as it is string)
        String imageURL = jsonDecode(result.body)['data'][0]['url'];
        imageURL = imageURL.trim();

        messages.add({
          'role': 'assistant',
          'content': imageURL,
        });
        return imageURL;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
