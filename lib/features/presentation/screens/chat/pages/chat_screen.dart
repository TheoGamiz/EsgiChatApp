import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListView(), // Utilisez ici le widget de la liste des messages
          ),
          MessageInput(), // Utilisez ici le widget de saisie des messages
        ],
      ),
    );
  }
}

class MessageListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ici, vous pouvez mettre en place la liste des messages avec les widgets nécessaires
    // Vous pouvez utiliser ListView.builder ou ListView.separated pour afficher les messages.
    return ListView.separated(
      itemBuilder: (context, index) {
        // Construire les widgets pour afficher chaque message
        return ListTile(
          title: Text('Message $index'),
          subtitle: Text('Message body...'),
        );
      },
      separatorBuilder: (context, index) => Divider(),
      itemCount: 20, // Remplacez ceci par le nombre réel de messages dans la conversation.
    );
  }
}

class MessageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ici, vous pouvez mettre en place le widget de saisie des messages
    // Par exemple, un TextField pour permettre à l'utilisateur de taper le message
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Ici, vous pouvez envoyer le message lorsque l'utilisateur appuie sur le bouton d'envoi.
            },
          ),
        ],
      ),
    );
  }
}

// Vous pouvez également ajouter d'autres widgets personnalisés pour la mise en forme des messages,
// les images de profil des utilisateurs, etc.
