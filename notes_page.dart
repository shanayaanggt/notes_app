import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';
import 'package:notes_app/note_database.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  final _noteDatabase = NoteDatabase();
  final searchController = TextEditingController();

  bool isSearching = false;
  bool isFilteredByFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) => setState(() {}),
              )
            : const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () => setState(() => isSearching = !isSearching),
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () =>
                setState(() => isFilteredByFavorite = !isFilteredByFavorite),
            icon: Icon(isFilteredByFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _noteDatabase.getNotesStream(),
        builder: (context, snapshot) {
          //loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          //loaded
          final notes = snapshot.data!;
          final searchedNotes = searchController.text.isEmpty
              ? notes
              : notes
                  .where((note) => note.content
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();

          // Filter by favorite
          final filteredNotes = isFilteredByFavorite
              ? searchedNotes
                  .where((searchedNotes) => searchedNotes.isFavorite)
                  .toList()
              : searchedNotes;

          //Empty state
          if (filteredNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(searchController.text.isEmpty
                      ? 'No notes found'
                      : 'No results found'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addNewNote,
                    child: const Text('Add New Note'),
                  ),
                ],
              ),
            );
          }

          //list of notes
          return ListView.separated(
            itemCount: filteredNotes.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 10,
            ),
            itemBuilder: (context, index) => ListTile(
              title: Text(filteredNotes[index].content),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editNote(filteredNotes[index]),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => deleteNote(filteredNotes[index]),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
              leading: filteredNotes[index].isFavorite
                  ? GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: const Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: const Icon(
                        Icons.star_border,
                      ),
                    ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              //create new note
              final note = Note(
                content: textController.text,
                isFavorite: false,
              );

              //save the note to the database
              _noteDatabase.insertNote(note);

              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void editNote(Note note) {
    textController.text = note.content;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              //Update the note
              note.content = textController.text;
              _noteDatabase.updateNote(note);

              //Close the dialog
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: Text("Content: \"${note.content}\""),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show a second confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Deletion"),
                  content:
                      const Text("Are you sure you want to delete this note"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Delete the note
                        _noteDatabase.deleteNote(note);
                        Navigator.pop(context); // Close second dialog
                      },
                      child: const Text('Yes, Delete'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void toggleFavorite(Note note) {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
  }
}
