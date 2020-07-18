import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:note_editor/menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

class Note {
  String filePath;
  DateTime created;
  DateTime lastModified;
  bool isFavourite;
  String title;
  String content;

  Note._internal(
      {@required this.filePath,
      @required this.created,
      @required this.lastModified,
      this.isFavourite = false,
      this.title = "New note",
      this.content = ""});

  factory Note.parse({@required String json}) {
    var data = jsonDecode(json);
    return Note._internal(
        filePath: data["filePath"],
        created: DateTime.parse(data["created"]),
        lastModified: DateTime.parse(data["lastModified"]),
        isFavourite: data["isFavourite"],
        title: data["title"],
        content: data["content"]);
  }

  Future<Note> save() async {
    var data = {
      "filePath": filePath,
      "created": created.toIso8601String(),
      "lastModified": DateTime.now().toIso8601String(),
      "isFavourite": isFavourite,
      "title": title,
      "content": content
    };
    var jsonString = jsonEncode(data);
    await noteFile.writeAsString(jsonString, flush: true, mode: FileMode.write);
    return this;
  }

  Future<Note> delete() async {
    try {
      await noteFile.delete();
    } catch(e) {
      debugPrint("While deleting: " + e.toString());
    }
    return this;
  }

  void setFavourite(bool value) {
    this.isFavourite = value;
    this.save();
  }

  File get noteFile => File(filePath);

  static Future<Note> generateEmpty({bool liked = false}) async => Note._internal(
        filePath: await _nextFilePath,
        created: DateTime.now(),
        lastModified: DateTime.now(),
        isFavourite: liked
      );

  static Future<String> get _nextFilePath async =>
      (await _noteDirPath) +
      "/note-${DateTime.now().millisecondsSinceEpoch}.json";
}

Future<String> get _noteDirPath async {
  var dir = await getApplicationDocumentsDirectory();
  var notesDir = Directory(dir.path + "/notes");
  if(!(await notesDir.exists()))
    await notesDir.create(recursive: true);
  return notesDir.path;
}

class NotesListManager {
  PublishSubject<List<Note>> _notesStream = PublishSubject<List<Note>>();
  Stream<List<Note>> get notes => _notesStream.stream;

  void refreshList({@required SearchFilter filter}) async {
    var dir = Directory(await _noteDirPath);
    var rawFiles = await dir
        .list()
        .where((file) => file.path.endsWith(".json"))
        .map((file) => File(file.path))
        .toList();

    var notesList = <Note>[];
    for (File f in rawFiles) {
      try {
        var contents = await f.readAsString();
        var noteFile = Note.parse(json: contents);
        notesList.add(noteFile);
      } catch (err) {
        debugPrint("Error while parsing a note file " + f.path);
      }
    }

    if(filter != null) {
      notesList = notesList.where(filter).toList();
    }

    _notesStream.add(notesList);
  }

  void dispose() {
    _notesStream.close();
  }
}

final noteNameValidationRegex = RegExp(r"^[a-zA-Z0-9-_ ]+$");

enum NoteSortingType {
  NameAscending,
  NameDescending,
  CreatedAscending,
  CreatedDescending,
  ModifiedAscending,
  ModifiedDescending
}

class NoteSorter {

  static int Function(Note, Note) getSorterFromType({@required NoteSortingType type}) {
    switch(type) {
      case NoteSortingType.NameAscending:
        return byNameAscending;
      case NoteSortingType.NameDescending:
        return byNameDescending;
      case NoteSortingType.CreatedAscending:
        return byDateCreatedAscending;
      case NoteSortingType.CreatedDescending:
        return byDateCreatedDescending;
      case NoteSortingType.ModifiedAscending:
        return byDateModifiedAscending;
      case NoteSortingType.ModifiedDescending:
        return byDateModifiedDescending;
    }
    return null;
  }

  static int byNameAscending(Note n1, Note n2) => n1.title.compareTo(n2.title);
  static int byNameDescending(Note n1, Note n2) => n2.title.compareTo(n1.title);

  static int byDateCreatedAscending(Note n1, Note n2) => n1.created.millisecondsSinceEpoch - n2.created.millisecondsSinceEpoch;
  static int byDateCreatedDescending(Note n1, Note n2) => n2.created.millisecondsSinceEpoch - n1.created.millisecondsSinceEpoch;

  static int byDateModifiedAscending(Note n1, Note n2) => n1.lastModified.millisecondsSinceEpoch - n2.lastModified.millisecondsSinceEpoch;
  static int byDateModifiedDescending(Note n1, Note n2) => n2.lastModified.millisecondsSinceEpoch - n1.lastModified.millisecondsSinceEpoch;
}