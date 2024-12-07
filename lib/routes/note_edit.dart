import 'package:flutter/material.dart';
import 'package:catatanqu/services/note_service.dart';
import 'package:catatanqu/models/note_model.dart';

class NoteEdit extends StatefulWidget {
  final int? id;
  final ValueChanged<int>? onSuccess;
  const NoteEdit({
    super.key,
    this.id,
    this.onSuccess,
  });

  @override
  State<NoteEdit> createState() => NoteEditState();
}

class NoteEditState extends State<NoteEdit> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _fetchNoteDetails();
    }
  }

  Future<void> _fetchNoteDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final note = await NoteService.fetchNoteDetails(widget.id!);
      if (note != null) {
        setState(() {
          _titleController.text = note.title;
          _contentController.text = note.content;
        });
      } else {
        setState(() {
          _error = 'Catatan tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      final message =
          (_titleController.text.isEmpty && _contentController.text.isEmpty)
              ? 'Judul dan isi catatan harus diisi'
              : (_titleController.text.isEmpty
                  ? 'Judul catatan harus diisi'
                  : 'Isi catatan harus diisi');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final note = NoteModel(
        id: widget.id ?? 0, // Provide default value for new notes
        title: _titleController.text,
        content: _contentController.text,
        updatedAt: DateTime.now(), // Current time for new/updated notes
      );

      if (widget.id != null) {
        await NoteService.updateNote(note);
      } else {
        await NoteService.createNote(note);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error ?? 'Terjadi kesalahan')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Tambah Catatan' : 'Edit Catatan'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
        ],
      ),
      body: _isLoading && widget.id != null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && widget.id != null
              ? Center(child: Text(_error!))
              : Padding(
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
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextField(
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          controller: _contentController,
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
