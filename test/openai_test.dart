import 'package:amadeus/openai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodeResult should return a Result object with the correct properties',
      () {
    const rawJson = r"""{
    "id": "chatcmpl-7pdy4RglWpa1h8qaw1lCtGincYY7D",
    "object": "chat.completion",
    "created": 1692542720,
    "model": "gpt-35-turbo",
    "choices": [
        {
            "index": 0,
            "finish_reason": "stop",
            "message": {
                "role": "assistant",
                "content": "Hi! I'm Forest, a hiking enthusiast. It sounds like you're planning a trip to Japan from Shanghai for a week. That's fantastic! Japan has a lot to offer in terms of hiking and outdoor activities. \n\nHere are three hiking suggestions for you in Japan:\n\n1. Mount Fuji: Located near Tokyo, Mount Fuji is Japan's highest and most iconic mountain. The hike to the summit takes around 5-8 hours depending on your speed and fitness level. It's a challenging hike, but the panoramic view from the top is absolutely breathtaking!\n\n2. Kamikochi: Situated in the Japanese Alps, Kamikochi is a beautiful valley known for its stunning mountain scenery. There are various trails of different lengths and difficulty levels to explore. One popular hike is the Taisho Pond Trail, which is a relatively easy hike that takes you past picturesque ponds and offers stunning views of the surrounding mountains.\n\n3. Kumano Kodo: If you're interested in a more cultural hiking experience, the Kumano Kodo pilgrimage trails in Wakayama Prefecture are a fantastic choice. These ancient trails have been used for centuries by pilgrims and offer a unique opportunity to immerse yourself in Japan's spiritual and natural heritage. The Nakahechi route is one of the most popular and takes you through beautiful forests and scenic villages.\n\nInteresting fact: Did you know that Mount Fuji is not only a famous hiking destination but also a sacred site in Japan? It has been an object of worship for centuries and has great cultural significance.\n\nI hope these suggestions help you plan your hiking adventure in Japan! Let me know if you have any other questions or if there's anything else I can assist you with. Enjoy your trip!"
            }
        }
    ],
    "usage": {
        "completion_tokens": 349,
        "prompt_tokens": 288,
        "total_tokens": 637
    }
}""";

    final result = OpenaiClient.decodeResult(rawJson);

    expect(result.isSuccess, true);
    expect(result.message,
        "Hi! I'm Forest, a hiking enthusiast. It sounds like you're planning a trip to Japan from Shanghai for a week. That's fantastic! Japan has a lot to offer in terms of hiking and outdoor activities. \n\nHere are three hiking suggestions for you in Japan:\n\n1. Mount Fuji: Located near Tokyo, Mount Fuji is Japan's highest and most iconic mountain. The hike to the summit takes around 5-8 hours depending on your speed and fitness level. It's a challenging hike, but the panoramic view from the top is absolutely breathtaking!\n\n2. Kamikochi: Situated in the Japanese Alps, Kamikochi is a beautiful valley known for its stunning mountain scenery. There are various trails of different lengths and difficulty levels to explore. One popular hike is the Taisho Pond Trail, which is a relatively easy hike that takes you past picturesque ponds and offers stunning views of the surrounding mountains.\n\n3. Kumano Kodo: If you're interested in a more cultural hiking experience, the Kumano Kodo pilgrimage trails in Wakayama Prefecture are a fantastic choice. These ancient trails have been used for centuries by pilgrims and offer a unique opportunity to immerse yourself in Japan's spiritual and natural heritage. The Nakahechi route is one of the most popular and takes you through beautiful forests and scenic villages.\n\nInteresting fact: Did you know that Mount Fuji is not only a famous hiking destination but also a sacred site in Japan? It has been an object of worship for centuries and has great cultural significance.\n\nI hope these suggestions help you plan your hiking adventure in Japan! Let me know if you have any other questions or if there's anything else I can assist you with. Enjoy your trip!");
    expect(result.completionTokens, 349);
    expect(result.promptTokens, 288);
  });
}
