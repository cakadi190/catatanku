import 'dart:convert';
import 'dart:io';
import 'package:catatanqu/models/note_model.dart';
import 'package:http/http.dart' as http;

class NoteService {
  static const String baseUrl = 'https://8080-proxy.catatancakadi.com/api';

  static Future<Map<String, dynamic>> fetchNotes(int page) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes?page=$page'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'notes': (data['data'] as List)
              .map((noteJson) => NoteModel.fromJson(noteJson))
              .toList(),
          'meta': data['meta']
        };
      } else {
        throw HttpException('Gagal memuat catatan: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('Tidak ada koneksi internet');
    } catch (e) {
      throw HttpException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  static Future<NoteModel?> fetchNoteDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NoteModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw HttpException('Gagal memuat detail catatan: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('Tidak ada koneksi internet');
    } catch (e) {
      throw HttpException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  static Future<NoteModel> createNote(NoteModel note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': note.title,
          'content': note.content,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NoteModel.fromJson(data);
      } else {
        throw HttpException('Gagal membuat catatan: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('Tidak ada koneksi internet');
    } catch (e) {
      throw HttpException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  static Future<void> updateNote(NoteModel note) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/${note.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': note.title,
          'content': note.content,
        }),
      );

      if (response.statusCode != 200) {
        throw HttpException('Gagal mengupdate catatan: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('Tidak ada koneksi internet');
    } catch (e) {
      throw HttpException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  static Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw HttpException('Gagal menghapus catatan: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('Tidak ada koneksi internet');
    } catch (e) {
      throw HttpException('Terjadi kesalahan: ${e.toString()}');
    }
  }
}