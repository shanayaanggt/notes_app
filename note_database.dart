import 'package:notes_app/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDatabase {
  //Instatiate new Database object
  final database = Supabase.instance.client.from('notes');

  //Insert a note to database
  Future<void> insertNote(Note note) async {
    await database.insert(note.toJson());
  }

  //Get a stream of notes from database

  Stream<List<Note>> getNotesStream() {
    return database.stream(primaryKey: ['id']).map(
        (data) => data.map((json) => Note.fromJson(json)).toList());
  }

  //update a note in the database
  Future<void> updateNote(Note note) async {
    await database.update(note.toJson()).eq('id', note.id!);
  }

  // Update the status of a note in the database
  Future<void> updateNoteStatus(int id, String newStatus) async {
    await database.update({'status': newStatus}).eq('id', id);
  }

  //Delete a note from database
  Future<void> deleteNote(Note note) async {
    await database.delete().eq('id', note.id!);
  }
}
