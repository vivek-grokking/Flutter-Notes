const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const dbName = "mynotes.db";
const notesTable = "notes";
const usersTable = "user";
const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id" INTEGER NOT NULL, 
          "email" TEXT NOT NULL UNIQUE, 
          PRIMARY KEY ("id" AUTOINCREMENT))
      ''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
        "id"INTEGER NOT NULL,
        "user_id" INTEGER NOT NULL,
        "text" TEXT,
        "is_synced_with_cloud" INTGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
