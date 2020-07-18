import 'dart:ui';

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:note_editor/noteModel.dart';
import 'package:note_editor/ui_helper.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriterPage extends StatefulWidget {
  static const String ROUTE = "/writer";
  static const firstOverlayKey = "first_writer_launch";

  @override
  _WriterPageState createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  bool _overlay = false;
  Note _writerNote;
  TextEditingController _noteEditingController = TextEditingController();
  bool _saved;

  @override
  void initState() {
    super.initState();
    _noteEditingController.addListener(() {
      if (_writerNote.content != _noteEditingController.text) {
        setState(() {
          _saved = false;
        });
        _writerNote.content = _noteEditingController.text;
      }
    });

    SharedPreferences.getInstance().then((spf) {
      if (!spf.containsKey(WriterPage.firstOverlayKey)) {
        spf
            .setBool(WriterPage.firstOverlayKey, true)
            .then((val) => setState(() => _overlay = true));
      } else {
        setState(() {
          _overlay = spf.getBool(WriterPage.firstOverlayKey);
        });
      }
    });
  }

  @override
  void dispose() {
    _noteEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_writerNote == null) {
      _writerNote = ModalRoute.of(context).settings.arguments as Note;
      _noteEditingController.text = _writerNote.content;
      _saved = true;
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_saved) {
          var result = await showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                    title: "Save",
                    message:
                        "There are unsaved changes in the note. Do you want to save them?",
                    okColor: Colors.grey[200],
                    cancelColor: Colors.grey[200],
                  ));
          if (result != null && result) {
            debugPrint("Saving file");
            await _writerNote.save();
          }
        }
        return true;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text(_writerNote.title),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Entypo.pencil),
                    onPressed: () async {
                      var noteName = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            return InputDialog(
                              title: "Enter note title",
                              initialText: _writerNote.title,
                              inputLabel: "Title",
                              validator: (input) =>
                                  noteNameValidationRegex.hasMatch(input),
                            );
                          });
                      if (noteName != null) {
                        setState(() {
                          _writerNote.title = noteName;
                          _saved = false;
                        });
                      }
                    }),
                IconButton(
                    icon: Icon(Entypo.save),
                    onPressed: _saved
                        ? null
                        : () async {
                            await _writerNote.save().then((val) => setState(() {
                                  _saved = true;
                                }));

                            showFlash(
                                context: context,
                                builder: (context, controller) {
                                  return Flash.bar(
                                    controller: controller,
                                    backgroundColor: Colors.black87,
                                    style: FlashStyle.floating,
                                    margin: const EdgeInsets.only(bottom: 60.0),
                                    child: FlashBar(
                                      message: Text(
                                        "File Saved!",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      icon: Icon(
                                        Entypo.save,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                                duration: const Duration(seconds: 2));
                          }),
              ],
            ),
            backgroundColor: Colors.grey[100],
            body: WriterWidget(_writerNote, _noteEditingController),
          ),

          !_overlay
              ? SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _overlay = false;
                    });
                    SharedPreferences.getInstance()
                        .then((spf) => spf.setBool(WriterPage.firstOverlayKey, false));
                  },
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: <Widget>[
                        Container(
                          color: Colors.black.withAlpha(180),
                        ),
                        Positioned(
                            right: 25,
                            top: 160,
                            child: overlayText(
                                icon: Entypo.save,
                                text: "Save note",
                                context: context)),
                        Positioned(
                            right: 25,
                            top: 120,
                            child: overlayText(
                                icon: Entypo.pencil,
                                text: "Edit note title",
                                context: context)),
                        Positioned(
                            right: 25,
                            bottom: 100,
                            child: overlayText(
                                icon: Entypo.heart,
                                text: "(Un)Favourite",
                                context: context)),
                        Positioned(
                            left: 25,
                            bottom: 100,
                            child: overlayText(
                                icon: Entypo.trash,
                                text: "Delete",
                                context: context)),
                        Positioned(
                            left: 120,
                            bottom: 160,
                            child: overlayText(
                                icon: Entypo.share,
                                text: "Share",
                                context: context)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class WriterWidget extends StatefulWidget {
  final Note writerNote;
  final TextEditingController noteEditingController;

  WriterWidget(this.writerNote, this.noteEditingController);

  @override
  _WriterWidgetState createState() => _WriterWidgetState();
}

class _WriterWidgetState extends State<WriterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: TextField(
            scrollPhysics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            controller: widget.noteEditingController,
            style: TextStyle(fontSize: 22),
            decoration: InputDecoration(
                border: OutlineInputBorder(
              borderSide: BorderSide.none,
            )),
            maxLines: null,
          ),
        )),
        BottomAppBar(
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  iconSize: 32,
                  icon: Icon(Entypo.trash),
                  color: Colors.black,
                  onPressed: () async {
                    var result = await showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmDialog(
                            title: "Delete this note",
                            message: "Are you sure?",
                            okColor: Colors.redAccent[100],
                            okTextColor: Colors.white,
                            cancelColor: Colors.grey[100],
                          );
                        });
                    if (result != null && result) {
                      widget.writerNote
                          .delete()
                          .then((value) => Navigator.of(context).pop());
                    }
                  }),
              IconButton(
                  icon: Icon(Entypo.share),
                  onPressed: () async {
                    var text = widget.noteEditingController.text;
                    await Share.share(
                      widget.noteEditingController.text,
                      subject: widget.writerNote.title,
                    );
                    widget.noteEditingController.text = text;
                    widget.noteEditingController.selection = TextSelection(
                        baseOffset: text.length, extentOffset: text.length);
                  }),
              IconButton(
                  iconSize: 32,
                  icon: Icon(widget.writerNote.isFavourite
                      ? Entypo.heart
                      : Entypo.heart_outlined),
                  color: widget.writerNote.isFavourite
                      ? Colors.redAccent
                      : Colors.black,
                  onPressed: () {
                    setState(() => widget.writerNote
                        .setFavourite(!widget.writerNote.isFavourite));
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
