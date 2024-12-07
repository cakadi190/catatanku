import 'package:flutter/material.dart';
import 'package:catatanqu/models/note_model.dart';
import 'package:catatanqu/services/note_service.dart';

class CreateNote extends StatefulWidget {
  final VoidCallback? onNoteCreated;
  final NoteModel? existingNote;

  const CreateNote({super.key, this.onNoteCreated, this.existingNote});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi catatan harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = NoteModel(
        id: widget.existingNote?.id ?? 0,
        title: _titleController.text,
        content: _contentController.text,
        updatedAt: DateTime.now(),
      );

      if (widget.existingNote == null) {
        await NoteService.createNote(note);
      } else {
        await NoteService.updateNote(note);
      }

      if (widget.onNoteCreated != null) {
        widget.onNoteCreated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingNote == null
                ? 'Catatan berhasil dibuat'
                : 'Catatan berhasil diperbarui'),
          ),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingNote == null ? 'Buat Catatan Baru' : 'Edit Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Judul',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
              ),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              decoration: const InputDecoration(
                hintText: 'Isi Catatan',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}