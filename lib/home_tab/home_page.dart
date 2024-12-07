import 'package:catatanqu/models/note_model.dart';
import 'package:catatanqu/routes/note_details.dart';
import 'package:catatanqu/routes/note_edit.dart';
import 'package:catatanqu/services/note_service.dart';
import 'package:catatanqu/utils/helper/date_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  final bool shouldRefresh;
  final VoidCallback? onRefreshComplete;

  const HomePage({
    super.key,
    required this.onTabChange,
    this.shouldRefresh = false,
    this.onRefreshComplete,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<NoteModel> _notes = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh) {
      refreshData();
      widget.onRefreshComplete?.call();
    }
  }

  Future<void> refreshData() async {
    try {
      await _loadData(refresh: true);
    } catch (e) {
      // Handle error
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadData();
    }
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (refresh) {
        _notes.clear();
        _currentPage = 1;
        _hasMore = true;
      }

      if (!_hasMore) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Kamu sudah mencapai akhir halaman!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await NoteService.fetchNotes(_currentPage);
      final fetchedNotes = result['notes'] as List<NoteModel>;
      final meta = result['meta'] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _notes.addAll(fetchedNotes);
          _currentPage++;
          _totalPages = meta['pages'] as int;
          _hasMore = _currentPage <= _totalPages;
        });
      }
    } catch (e) {
      if (mounted) {
        var message = !e.toString().contains('404')
            ? e.toString()
            : 'Tidak ada catatan sama sekali. Silahkan buat baru.';
        var bgColor =
            !e.toString().contains('404') ? Colors.red : Colors.blue[300];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 3),
          ),
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

  Future<void> _onRefresh() async {
    await _loadData(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_notes.isEmpty && !_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.note_add,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum ada catatan',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onTabChange.call(1);
                },
                child: const Text('Buat Catatan Pertama'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _notes.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _notes.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final note = _notes[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NoteDetails(id: int.parse(note.id.toString())),
                  ),
                );
              },
              title: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: FutureBuilder<String>(
                future: dateFormatter(
                  date: DateTime.parse(note.updatedAt.toString()),
                  format: 'dd MMMM yyyy HH.mm \W\I\B',
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  } else {
                    return const Text('');
                  }
                },
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) async {
                  switch (value) {
                    case 'ubah':
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEdit(
                            id: int.parse(note.id.toString()),
                          ),
                        ),
                      );

                      if (result == true) {
                        await _loadData(refresh: true);
                      }
                      break;
                    case 'hapus':
                      _deleteItem(int.parse(note.id.toString()));
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
              ),
            );
          },
        ),
      ),
    );
  }

  void _deleteItem(int index) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await NoteService.deleteNote(index);
      await _loadData(refresh: true);
    }
  }
}
