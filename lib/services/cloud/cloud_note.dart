import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_constants.dart';

@immutable
class CloudNote {
  final String ownerUserId;
  final String text;
  final String documentId;

  const CloudNote({
    required this.ownerUserId,
    required this.text,
    required this.documentId,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
