import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'notes_screen.dart';
import '../models/note_model.dart';

class UpdateNoteScreen extends StatefulWidget {
  final NoteModel note;
  const UpdateNoteScreen({super.key, required this.note});
  @override
  State<UpdateNoteScreen> createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.noteTitle);
    contentController = TextEditingController(text: widget.note.noteContent);
  }

  Future<void> updateNote() async {
    try {
      int result = await db.updateNote(
        titleController.text,
        contentController.text,
        widget.note.noteId!,
      );
      if (!mounted) return;
      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note updated successfully!'),
            backgroundColor: Colors.teal[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update note. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating the note.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Update Note", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                updateNote();
              }
            },
            icon: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              // TextField untuk input judul
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // TextField untuk input isi catatan/note
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Content is required";
                  }
                  return null;
                },
                maxLines: 5,
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
