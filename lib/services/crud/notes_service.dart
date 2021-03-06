// import 'dart:async';

// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'crud_constants.dart';
// import 'crud_exceptions.dart';
// import 'database_note.dart';
// import 'database_user.dart';

// class NotesService {
//   Database? _db;
//   List<DatabaseNote> _notes = [];
//   DatabaseUser? _user;

//   NotesService._sharedInstance() {
//     _notesStreamController =
//         StreamController<List<DatabaseNote>>.broadcast(onListen: () {
//       _notesStreamController.sink.add(_notes);
//     });
//   } // private constructor

//   static final NotesService _shared =
//       NotesService._sharedInstance(); // create private shared instance
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeWeReadNotesException();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on UserDoesNotExistsException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow; // only for debugging
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await _getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(
//         docsPath.path,
//         dbName,
//       );
//       final db = await openDatabase(dbPath);
//       _db = db;

//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       usersTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       usersTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }
//     final userId = await db.insert(
//       usersTable,
//       {emailColumn: email.toLowerCase()},
//     );
//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       usersTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw UserDoesNotExistsException();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final dbUser = await getUser(email: owner.email);

//     // make user owner exists
//     if (dbUser != owner) {
//       throw UserDoesNotExistsException();
//     }
//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//     final note = DatabaseNote(
//       id: noteId,
//       text: text,
//       userId: owner.id,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(notesTable);
//     _notes.clear();
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   Future<DatabaseNote> getNote({required int noteId}) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [noteId],
//     );
//     if (notes.isEmpty) {
//       throw NoteDoesNotExistsException();
//     } else {
//       final note = DatabaseNote.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == noteId);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<DatabaseNote>> _getAllNotes() async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       notesTable,
//     );
//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIdOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure note exists
//     await getNote(noteId: note.id);
//     final updatesCount = await db.update(
//         notesTable,
//         {
//           textColumn: text,
//           isSyncedWithCloudColumn: 0,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id]);
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(noteId: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<void> _ensureDbIdOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }
// }
