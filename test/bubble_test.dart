// class MockBubblePlatform
//     with MockPlatformInterfaceMixin
//     implements BubblePlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final BubblePlatform initialPlatform = BubblePlatform.instance;
//
//   test('$MethodChannelBubble is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelBubble>());
//   });
//
//   test('getPlatformVersion', () async {
//     Bubble bubblePlugin = Bubble();
//     MockBubblePlatform fakePlatform = MockBubblePlatform();
//     BubblePlatform.instance = fakePlatform;
//
//     expect(await bubblePlugin.getPlatformVersion(), '42');
//   });
// }
