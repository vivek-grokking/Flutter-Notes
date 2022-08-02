import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_constants.dart';
import 'package:mynotes/services/cloud/cloud_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';

class FirebaseCloudStorage {
  // private constructor
  FirebaseCloudStorage._sharedInstance();

  // private shared instance
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  // factory constructor which is the public default constructor of the class
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({
    required String ownerUserid,
  }) =>
      notes.snapshots().map(
          (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
                (note) => note.ownerUserId == ownerUserid,
              ));

  Future<Iterable<CloudNote>> getNotes({
    required String ownerUserid,
  }) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserid,
          )
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({
    required String ownerUserId,
  }) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }
}