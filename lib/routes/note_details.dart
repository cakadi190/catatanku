import 'package:catatanqu/models/note_model.dart';
import 'package:catatanqu/routes/note_edit.dart';
import 'package:catatanqu/services/note_service.dart';
import 'package:catatanqu/utils/helper/date_helper.dart';
import 'package:flutter/material.dart';

class NoteDetails extends StatefulWidget {
  final int id;
  const NoteDetails({super.key, required this.id});

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  late Future<NoteModel?> _noteFuture;

  @override
  void initState() {
    super.initState();
    _fetchNoteDetails();
  }

  Future<void> _fetchNoteDetails() async {
    setState(() {
      _noteFuture = NoteService.fetchNoteDetails(widget.id);
    });
  }

  Future<void> _refreshNote() async {
    await _fetchNoteDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) async {
              switch (value) {
                case 'ubah':
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEdit(id: widget.id)
                    )
                  );
                  if (result == true) {
                    await _refreshNote();
                  }
                  break;
                case 'hapus':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Catatan'),
                      content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await NoteService.deleteNote(widget.id);
                    Navigator.of(context).pop(true);
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'ubah',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Ubah'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'hapus',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Hapus'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder<NoteModel?>(
        future: _noteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 8),
                  const Text('Terjadi kesalahan',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                      "${snapshot.error ?? 'Ada kesalahan ketika memuat detail catatan'}. Coba lagi dengan menekan tombol di bawah.",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center),
                  TextButton(
                      onPressed: _refreshNote, child: const Text('Coba Lagi'))
                ],
              ),
            );
          }

          final note = snapshot.data;
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: dateFormatter(
                    date: DateTime.parse(note.updatedAt.toString()),
                    format: 'dd MMMM yyyy HH.mm \W\I\B',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var date = snapshot.data!;
                      return Text('Diubah pada $date', style: TextStyle(color: Colors.black.withOpacity(0.75)));
                    } else {
                      return Text('Tidak diketahui', style: TextStyle(color: Colors.black.withOpacity(0.75)));
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  note.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}