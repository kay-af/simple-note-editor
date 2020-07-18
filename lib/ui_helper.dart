import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:note_editor/noteModel.dart';
import 'package:url_launcher/url_launcher.dart';

class InputDialog extends StatefulWidget {
  final String title;
  final String inputLabel;
  final String okLabel;
  final String cancelLabel;
  final String initialText;
  final bool Function(String) validator;

  InputDialog(
      {this.title = "Title",
      this.inputLabel = "Input",
      this.okLabel = "Done",
      this.cancelLabel = "Cancel",
      this.initialText = "",
      this.validator});

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  bool isValid = false;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText;
    _textController.addListener(() => setState(
        () => isValid = widget.validator(_textController.text.trim())));
    _textController.selection =
        TextSelection(baseOffset: 0, extentOffset: _textController.text.length);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    hintText: widget.inputLabel,
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text(widget.cancelLabel)),
                FlatButton(
                    onPressed: this.isValid
                        ? () {
                            Navigator.of(context)
                                .pop(_textController.text.trim());
                          }
                        : null,
                    child: Text(widget.okLabel)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String okLabel;
  final String cancelLabel;
  final Color okColor;
  final Color cancelColor;
  final Color okTextColor;
  final Color cancelTextColor;

  ConfirmDialog(
      {@required this.title,
      @required this.message,
      this.okLabel = "Yes",
      this.cancelLabel = "No",
      this.okColor = Colors.white,
      this.cancelColor = Colors.white,
      this.okTextColor = Colors.black,
      this.cancelTextColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                    color: cancelColor,
                    textColor: cancelTextColor,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel)),
                FlatButton(
                    color: okColor,
                    textColor: okTextColor,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(okLabel)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget body;

  CustomDialog({@required this.title, @required this.body});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 16,
            ),
            body,
          ],
        ),
      ),
    );
  }
}

Widget labelledText(
    {@required String label,
    @required String text,
    @required BuildContext context}) {
  return Text.rich(
    TextSpan(children: [
      TextSpan(
          text: text,
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(fontWeight: FontWeight.w600)),
    ], text: "$label: ", style: Theme.of(context).textTheme.subtitle),
    overflow: TextOverflow.ellipsis,
  );
}

Future<T> showDefaultBottomSheet<T>(
    {@required BuildContext context, @required Widget body}) async {
  return await showModalBottomSheet<T>(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (context) => DefaultBottomSheet(
            body: body,
          ));
}

class DefaultBottomSheet extends StatelessWidget {
  final Widget body;

  DefaultBottomSheet({@required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: body,
      padding: const EdgeInsets.all(22.0),
    );
  }
}

class NoteSorterWidget extends StatefulWidget {
  final NoteSortingType currentSortingType;
  final bool categorize;

  NoteSorterWidget(
      {@required this.currentSortingType, @required this.categorize});

  @override
  _NoteSorterWidgetState createState() => _NoteSorterWidgetState();
}

class _NoteSorterWidgetState extends State<NoteSorterWidget> {
  bool _categorize;

  @override
  void initState() {
    super.initState();
    _categorize = widget.categorize;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(
            {"categorize": _categorize, "type": widget.currentSortingType});
        return false;
      },
      child: Column(
        children: <Widget>[
          Text(
            "Sort notes according to",
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          CheckboxListTile(
              title: Text("Categorize"),
              subtitle: Text("Separate results of similar kind"),
              value: _categorize,
              onChanged: (val) {
                setState(() => _categorize = val);
              }),
          Divider(),
          Expanded(
              child: ListView.separated(
            separatorBuilder: (context, i) => Divider(),
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, i) {
              String label = "";
              switch (i) {
                case 2:
                  label = "Ascending order of creation time";
                  break;
                case 3:
                  label = "Descending order of creation time";
                  break;
                case 4:
                  label = "Ascending order of last modification time";
                  break;
                case 5:
                  label = "Descending order of last modification time";
                  break;
                case 0:
                  label = "Ascending order of note name";
                  break;
                case 1:
                  label = "Descending order of note name";
                  break;
              }
              return ListTileTheme(
                selectedColor: Colors.blueAccent,
                child: ListTile(
                  trailing:
                      NoteSortingType.values[i] == widget.currentSortingType
                          ? Icon(Icons.check)
                          : SizedBox.shrink(),
                  selected:
                      NoteSortingType.values[i] == widget.currentSortingType,
                  title: Text(label),
                  onTap: () => Navigator.of(context).pop({
                    "categorize": _categorize,
                    "type": NoteSortingType.values[i]
                  }),
                ),
              );
            },
            itemCount: 6,
          ))
        ],
      ),
    );
  }
}

class AboutAppDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "About",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Divider(),
            SizedBox(
              height: 16,
            ),
            Text(
              _about,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 12,
            ),
            IconButton(
              iconSize: 38,
              icon: Icon(Ionicons.logo_github),
              onPressed: () async => await launch(_githubLink),
            ),
            Divider(),
            SizedBox(
              height: 16,
            ),
            Text(
              "Find me",
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    iconSize: 38,
                    icon: Icon(Ionicons.logo_facebook),
                    color: Colors.blue,
                    onPressed: () async => await launch(_facebookLink)),
                IconButton(
                    iconSize: 38,
                    color: Colors.pink,
                    icon: Icon(Ionicons.logo_instagram),
                    onPressed: () async => await launch(_instagramLink)),
                IconButton(
                    iconSize: 38,
                    color: Colors.purple,
                    icon: Icon(Ionicons.logo_linkedin),
                    onPressed: () async => await launch(_linkedInLink)),
              ],
            ),
            Divider(),
            CloseButton(),
          ],
        ),
      ),
    );
  }
}

Widget overlayText(
    {@required String text, @required BuildContext context, IconData icon}) {
  if (icon == null) {
    return Text(
      "$text",
      style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
    );
  }
  else {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
        children: [
          WidgetSpan(child: Icon(icon, color: Colors.white,)),
          WidgetSpan(child: SizedBox(width: 16,)),
          TextSpan(text: "$text"),
        ]
      ),
    );
  }
}

const String _about =
    "This application is open-source. Code can be found on github";
const String _githubLink = "https://github.com/kay-af/simple-note-editor";
const String _facebookLink = "https://www.facebook.com/afridi.kayal.3";
const String _instagramLink = "https://www.instagram.com/_frid.c";
const String _linkedInLink =
    "https://www.linkedin.com/in/afridi-kayal-ba110719b";
