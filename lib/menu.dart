import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:note_editor/noteModel.dart';
import 'package:note_editor/ui_helper.dart';
import 'package:note_editor/writer.dart';
import 'package:share/share.dart';

typedef bool SearchFilter(Note note);

class MenuPage extends StatefulWidget {
  static const String ROUTE = "/menu";

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final NotesListManager _notesListManager = NotesListManager();

  bool _fav = false;
  TabController _tabController;
  NoteSortingType _noteSortingType = NoteSortingType.CreatedDescending;
  bool _separate = true;
  bool _searchExpanded = false;

  TextEditingController _searchTextEditingController;
  SearchFilter _searchFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController
        .addListener(() => setState(() => _fav = _tabController.index == 1));
    _searchTextEditingController = TextEditingController();

    _searchTextEditingController.addListener(() {
      setState(
          () => _searchFilter = _searchTextEditingController.text.trim().isEmpty
              ? null
              : (note) {
                  return note.title.toLowerCase().contains(
                          _searchTextEditingController.text.toLowerCase()) ||
                      note.content.toLowerCase().contains(
                          _searchTextEditingController.text.toLowerCase());
                });
      _notesListManager.refreshList(filter: _searchFilter);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesListManager.dispose();
    _searchTextEditingController.dispose();
    super.dispose();
  }

  void resetSearchFilter() {
    _searchExpanded = false;
    _searchTextEditingController.text = "";
    _searchFilter = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Entypo.info_with_circle),
            onPressed: () async {
              await showDialog(
                  context: context, builder: (context) => AboutAppDialog());
            }),
        title: Text("Notes"),
        bottom: !_searchExpanded
            ? null
            : PreferredSize(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: TextField(
                    autofocus: true,
                    controller: _searchTextEditingController,
                    decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Entypo.magnifying_glass,
                            color: Colors.grey[400]),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(0.0)),
                  ),
                ),
                preferredSize: Size.fromHeight(64)),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Entypo.magnifying_glass,
                color: _searchExpanded ? Colors.blue : Colors.black,
              ),
              onPressed: () {
                _searchTextEditingController.text = "";
                setState(() {
                  _searchFilter = null;
                  _searchExpanded = !_searchExpanded;
                });
              }),
          IconButton(
              icon: Icon(Entypo.area_graph),
              onPressed: () async {
                var result = await showDefaultBottomSheet(
                    context: context,
                    body: NoteSorterWidget(
                      categorize: _separate,
                      currentSortingType: _noteSortingType,
                    ));
                if (result != null) {
                  setState(() {
                    _noteSortingType = result["type"];
                    _separate = result["categorize"];
                  });
                  _notesListManager.refreshList(filter: _searchFilter);
                }
              }),
          IconButton(
            icon: Icon(FontAwesome.plus),
            onPressed: () async {
              var emptyNote = await Note.generateEmpty(liked: _fav);
              await Navigator.of(context)
                  .pushNamed(WriterPage.ROUTE, arguments: emptyNote);

              resetSearchFilter();

              Future.delayed(Duration(milliseconds: 200)).then((val) =>
                  _notesListManager.refreshList(filter: _searchFilter));
            },
          ),
        ],
      ),
      body: MenuWidget(
        notesListManager: _notesListManager,
        fav: _fav,
        sortingType: _noteSortingType,
        categorize: _separate,
        searchFilter: _searchFilter,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(controller: _tabController, tabs: [
          Tab(
            icon: Icon(FontAwesome.sticky_note),
            text: "All",
          ),
          Tab(
            icon: Icon(FontAwesome.heart),
            text: "Favourites",
          ),
        ]),
      ),
    );
  }
}

class MenuWidget extends StatefulWidget {
  final bool fav;
  final NotesListManager notesListManager;
  final NoteSortingType sortingType;
  final bool categorize;
  final SearchFilter searchFilter;

  MenuWidget(
      {@required this.notesListManager,
      @required this.fav,
      @required this.sortingType,
      @required this.categorize,
      @required this.searchFilter,
      Key key})
      : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  void initState() {
    super.initState();
    widget.notesListManager.refreshList(filter: widget.searchFilter);
  }

  @override
  Widget build(BuildContext context) {
    return _getView(fav: widget.fav);
  }

  Widget _getView({@required bool fav}) {
    return Container(
      child: StreamBuilder<List<Note>>(
        stream: widget.notesListManager.notes,
        builder: (context, notesSnapshot) {
          if (!notesSnapshot.hasData) {
            return Center(
              child: SpinKitFadingCircle(
                color: Colors.black,
              ),
            );
          } else if (notesSnapshot.hasError) {
            debugPrint(notesSnapshot.error.toString());
            return SizedBox.shrink();
          } else {
            var data = notesSnapshot.data;
            if (fav) {
              data = data.where((n) => n.isFavourite).toList();
            }

            data.sort(NoteSorter.getSorterFromType(type: widget.sortingType));

            // If there are zero notes
            if (data.length == 0) {
              return Center(
                child: Text(
                  widget.searchFilter != null
                      ? "No search results!"
                      : fav
                          ? "No favourite notes!\nTap the heart to mark a note as favourite"
                          : "You have no notes!",
                  textAlign: TextAlign.center,
                ),
              );
            }

            // If there are notes
            var dateFormat = DateFormat("hh:mm a, dd/MM/yyyy");

            // Pump category if enabled
            List pumpedData = data;
            if (widget.categorize)
              pumpedData =
                  pumpCategory(list: data, pumpType: widget.sortingType);

            return ListView.builder(
              itemCount: pumpedData.length,
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, i) {
                if (pumpedData[i] is String) {
                  // Pumped text
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Stack(
                      fit: StackFit.passthrough,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Divider(),
                        Text(
                          pumpedData[i],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.caption.apply(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor),
                        ),
                      ],
                    ),
                  );
                }

                var note = pumpedData[i] as Note;
                return Container(
                  decoration: BoxDecoration(color: Colors.white70),
                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                  child: ListTile(
                    onLongPress: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              title: "Properties",
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  labelledText(
                                      label: "Title",
                                      text: note.title,
                                      context: context),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  labelledText(
                                      label: "Created",
                                      text: dateFormat.format(note.created),
                                      context: context),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  labelledText(
                                      label: "Modified",
                                      text:
                                          dateFormat.format(note.lastModified),
                                      context: context),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(Entypo.share),
                                          onPressed: () async {
                                            await Share.share(
                                              note.content,
                                              subject: note.title,
                                            );
                                          }),
                                      IconButton(
                                          icon: Icon(Entypo.pencil),
                                          onPressed: () async {
                                            Navigator.of(context).pop("title");
                                          }),
                                      IconButton(
                                          icon: Icon(Entypo.trash),
                                          onPressed: () async {
                                            Navigator.of(context).pop("delete");
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          });

                      if (result == "delete") {
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
                          note.delete().then((value) => widget.notesListManager
                              .refreshList(filter: widget.searchFilter));
                        }
                      } else if (result == "title") {
                        var noteName = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return InputDialog(
                                title: "Enter note title",
                                initialText: note.title,
                                inputLabel: "Title",
                                validator: (input) =>
                                    noteNameValidationRegex.hasMatch(input),
                              );
                            });
                        if (noteName != null) {
                          note.title = noteName;
                          note.save().then((val) =>
                              Future.delayed(const Duration(milliseconds: 200))
                                  .then((val) => widget.notesListManager
                                      .refreshList(
                                          filter: widget.searchFilter)));
                        }
                      }
                    },
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed(WriterPage.ROUTE, arguments: note);

                      Future.delayed(Duration(milliseconds: 200)).then((val) =>
                          widget.notesListManager
                              .refreshList(filter: widget.searchFilter));
                    },
                    title: Text(
                      note.title,
                      style: Theme.of(context).textTheme.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          note.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Last Modified: ${dateFormat.format(note.lastModified)}",
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      iconSize: 32,
                      icon: Icon(note.isFavourite
                          ? Entypo.heart
                          : Entypo.heart_outlined),
                      onPressed: () {
                        setState(() {
                          note.setFavourite(!note.isFavourite);
                        });
                      },
                      color: note.isFavourite ? Colors.redAccent : Colors.black,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  List pumpCategory(
      {@required List<Note> list, @required NoteSortingType pumpType}) {
    var pumped = [];
    var dateFormat = DateFormat("dd/MM/yyyy");

    if (pumpType == NoteSortingType.CreatedAscending ||
        pumpType == NoteSortingType.CreatedDescending) {
      DateTime lastValue;
      list.forEach((item) {
        if (lastValue == null) {
          lastValue = item.created;
          pumped.add(dateFormat.format(item.created));
        } else {
          var current = item.created;
          if (!isSameDate(current, lastValue)) {
            pumped.add(dateFormat.format(current));
            lastValue = current;
          }
        }
        pumped.add(item);
      });
    } else if (pumpType == NoteSortingType.ModifiedAscending ||
        pumpType == NoteSortingType.ModifiedDescending) {
      DateTime lastValue;
      list.forEach((item) {
        if (lastValue == null) {
          lastValue = item.created;
          pumped.add(dateFormat.format(item.lastModified));
        } else {
          var current = item.lastModified;
          if (!isSameDate(current, lastValue)) {
            pumped.add(dateFormat.format(current));
            lastValue = current;
          }
        }
        pumped.add(item);
      });
    } else {
      String lastValue;
      list.forEach((item) {
        var current = item.title[0];
        if (lastValue == null) {
          lastValue = current[0];
          pumped.add(current.toUpperCase());
        } else {
          if (current != lastValue) {
            pumped.add(current.toUpperCase());
            lastValue = current;
          }
        }
        pumped.add(item);
      });
    }

    return pumped;
  }

  bool isSameDate(DateTime first, DateTime other) {
    return first.year == other.year &&
        first.month == other.month &&
        first.day == other.day;
  }
}
