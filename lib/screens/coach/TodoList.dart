import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late User loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            ///
            stream: _fireStore
                .collection('todo')
                .orderBy('created', descending: false)
                .snapshots(),

            ///flutter aysnc snapshot
            builder: (context, snapshot) {
              List<MessageBubble> todoWidgets = [];
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                );
              }
              final todoLists = snapshot.data!.docs;

              for (var todoList in todoLists) {
                final day = (todoList.data() as dynamic)['day'];

                final place = (todoList.data() as dynamic)['place'];

                final task = (todoList.data() as dynamic)['task'];

                final time = (todoList.data() as dynamic)['time'];

                final loggedIn = (todoList.data() as dynamic)['sender'];

                final currentUser = loggedInUser.email;
                print('Current user $currentUser');
                print('logged user $loggedIn');

                final messageWidget = MessageBubble(
                  day: '$day',
                  isLoggedIn: currentUser == loggedIn,
                  place: '$place',
                  task: '$task',
                  time: '$time',
                );

                todoWidgets.add(messageWidget);
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(children: todoWidgets),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.isLoggedIn,
      required this.day,
      required this.task,
      required this.time,
      required this.place});
  final String day;
  final String task;
  final String time;
  final String place;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text('$task',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)),
            ],
          ),
          Material(
              elevation: 5.0,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0)),
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$day',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$place',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$time',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
