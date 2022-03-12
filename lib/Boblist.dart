import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BobList extends StatelessWidget {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('whenBob').where('when', isGreaterThan: DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()))).orderBy('when', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else
          return ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: snapshot.data!.docs.map((doc) {
              return Card(
                elevation: 0.0,
                child: ListTile(
                  tileColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  title: Text(
                      DateFormat('yyyy-MM-dd – kk:mm').format(doc['when'].toDate()),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'JejuGothic'),
                  ),
                ),
              );
            }).toList(),
          );
      },
    );
  }
}
