import 'package:esgi_chat_app/features/models/message.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  final String friendUid;
  final String roomId;
  final String userId;

  ChatPage({
    required this.friendUid,
    required this.roomId,
    required this.userId,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ID: $roomId'),
      ),
      body: ChatWidget(
        friendUid: friendUid,
        roomId: roomId,
        userId: userId,
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  final String friendUid;
  final String roomId;
  final String userId;

  const ChatWidget({
    required this.friendUid,
    required this.roomId,
    required this.userId,
  }) : super();

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  List<types.Message> _messages = [];
  late final types.User _user;

  @override
  void initState() {
    super.initState();
    _user = types.User(
      id: widget.userId,
    );
    _loadMessages(widget.roomId);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType:
            lookupMimeType(result.files.single.path ?? '') ?? 'application/*',
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path ?? '',
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    final roomId = widget.roomId;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userDoc = await firestore
        .collection('users')
        .doc(widget.friendUid.toString())
        .get();
    final blockedFriends = List<String>.from(userDoc.get('bloque') ?? []);
    if (blockedFriends.contains(widget.userId)) {
      // Friend is blocked, don't send the message
      print('You cannot send a message to this friend as they are blocked.');
      Fluttertoast.showToast(
        msg: 'Cet utilisateur vous a bloqué',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Save the message to the room's "messages" collection in Firestore
    try {
      print("TRY");
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'text': message.text,
        'senderId': _user.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erreur lors de l'envoi du message : $e");
    }

    _addMessage(textMessage);
  }

  List<types.Message> convertToMessagesList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots) {
    return snapshots
        .map((snapshot) {
          final data = snapshot.data();
          print("authorId ${data['senderId']}");
          print("1");
          final authorId = data['senderId'] ?? "";
          final createdAt =
              (data['timestamp'] as Timestamp?)?.millisecondsSinceEpoch;
          final id = snapshot.id;
          final text = data['text'] as String?;

          types.TextMessage msg1 = types.TextMessage.fromJson({
            "author": {"id": authorId},
            "createdAt": createdAt,
            "id": id,
            "text": data["text"]
          });
          //types.Message msg = types.Message.fromJson(data);

          return msg1;
        })
        .where((message) => message != null)
        .toList();
  }

  void _loadMessages(String roomId) {
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot == null || snapshot.docs.isEmpty) {
        print("No messages found in the collection.");
        setState(() {
          _messages = [];
        });
        return;
      }

      final messages = snapshot.docs.toList();

      setState(() {
        _messages = convertToMessagesList(messages);
      });
    }, onError: (error) {
      print("Error fetching messages: $error");
      setState(() {
        _messages = [];
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
        ),
      );
}
