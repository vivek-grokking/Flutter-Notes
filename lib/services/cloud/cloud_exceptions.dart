class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}
