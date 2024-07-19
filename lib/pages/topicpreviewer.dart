// ignore_for_file: use_build_context_synchronously

import 'package:degreen/topics.dart';
import 'package:degreen/utils/content.dart';
import 'package:degreen/utils/itembox.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:degreen/utils/storage_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'dart:math' as math;

class Topicpreviewer extends StatefulWidget {
  final String topic;
  final List descriptions;
  final IconData icondata;
  const Topicpreviewer({
    super.key,
    required this.topic,
    required this.descriptions,
    required this.icondata,
  });

  @override
  State<Topicpreviewer> createState() => _TopicpreviewerState();
}

class _TopicpreviewerState extends State<Topicpreviewer> {
  bool leftpanel = false,
      ascending = true,
      tophide = false,
      _isDescriptionVisible = false,
      outfocus = true,
      searchactive = false,
      mininput = false,
      isSpeaking = false;
  String sortCriterion = 'date',
      answer = "",
      speakstring = "",
      selectedText = "",
      wordmean = "",
      littleload = "",
      activesubtitle = "";
  late ScrollController scrollController;
  ScrollController tscrollController = ScrollController();
  double scrollyoffset = 0;
  late ScrollController _scrollController;
  int active = 0;
  double fontSize = 14.0;
  FlutterTts flutterTts = FlutterTts();
  Widget children = const SizedBox();
  final TextEditingController _searchController = TextEditingController(),
      _titleController = TextEditingController(),
      _subtitleController = TextEditingController(),
      _contentController = TextEditingController();
  List<Content> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    _loadContent();
    _searchController.addListener(filterItems);
  }

  void saveItem() {
    final title = "${_titleController.text}-::::-${_subtitleController.text}";
    final content = _contentController.text;
    if (_titleController.text.isNotEmpty &&
        _subtitleController.text.isNotEmpty &&
        content.isNotEmpty) {
      final newContent = Content(
        title: title,
        datetime: DateTime.now(),
        content: content,
      );
      StorageHelper.addContent(newContent);
      StorageHelper.saveContentToFile(newContent);
      Navigator.pop(context);
      errormsg(context: context, error: 'Item Saved');
      _loadContent();
    } else {
      errormsg(
          context: context,
          error: 'Title, Subtitle and content cannot be empty');
    }
  }

  void increaseFontSize() {
    setState(() {
      fontSize += 2.0;
    });
  }

  void _loadContent() {
    setState(() {
      _filteredItems = StorageHelper.getAllContent();
      _sortContent();
    });
  }

  void _sortContent() {
    setState(() {
      _filteredItems.sort((a, b) => a.datetime.compareTo(b.datetime));
    });
  }

  void _deleteContent(int index) {
    final content = _filteredItems[index];
    StorageHelper.deleteContent(index);
    StorageHelper.deleteContentFromFile(content.datetime);
    _loadContent();
  }

  void _updateContent(int index, String newTitle, String oldtitle,
      String oldsubtitle, String newContent) {
    if (oldtitle.isNotEmpty &&
        oldsubtitle.isNotEmpty &&
        newContent.isNotEmpty) {
      final updatedContent = Content(
        title: newTitle,
        datetime: _filteredItems[index].datetime,
        content: newContent,
      );
      StorageHelper.updateContent(index, updatedContent);
      _loadContent();

      Navigator.pop(context);
      errormsg(context: context, error: "Item Updated!");
    } else {
      errormsg(
          context: context,
          error: 'Title, Subtitle and content cannot be empty');
    }
  }

  void resetFontSize() {
    setState(() {
      fontSize = 14.0;
    });
  }

  Future<void> speak(
      {required String textToConvert,
      required BuildContext context,
      required double rate}) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.setSpeechRate(rate);
      await flutterTts.speak(textToConvert);
      setState(() {
        isSpeaking = true;
      });

      flutterTts.setCompletionHandler(() {
        setState(() {
          isSpeaking = false;
        });
      });
    } catch (e) {
      errormsg(context: context, error: "An error occured");
    }
  }

  void errormsg({required BuildContext context, required String error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      error,
      textAlign: TextAlign.center,
    )));
  }

  Future<void> stopspeaking() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    _searchController.removeListener(filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isDescriptionVisible) {
      setState(() {
        _isDescriptionVisible = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isDescriptionVisible = false;
        });
      });
    }
  }

  void onScroll() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (tophide) {
        setState(() {
          tophide = false;
        });
      }
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!tophide) {
        setState(() {
          tophide = true;
        });
      }
    }
  }

  void filterItems() {
    String query = _searchController.text.toLowerCase();
    _loadContent();
    setState(() {
      _filteredItems = _filteredItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    String deviceType = "";
    if (deviceWidth >= 1200) {
      deviceType = 'huge';
    } else if (deviceWidth >= 700) {
      deviceType = 'tablet';
    } else {
      deviceType = 'mobile';
    }
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        endDrawer: Drawer(
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Saved Items"),
                    searchactive
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            height: 50,
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'Search',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          )
                        : Text(
                            widget.topic,
                            style: const TextStyle(fontSize: 14),
                          ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          searchactive = !searchactive;
                        });
                      },
                      icon: !searchactive
                          ? const Icon(Icons.search_rounded)
                          : const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
              _filteredItems.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No items found')),
                    )
                  : SliverList.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final content = _filteredItems[index];
                        return Itembox(
                          title: content.title,
                          content: content.content,
                          datetime: content.datetime.toIso8601String(),
                          edit: () {
                            _showEditDialog(index);
                          },
                          delete: () {
                            _deleteContent(index);
                          },
                        );
                      },
                    )
            ],
          ),
        ),
        body: SizedBox(
          child: Stack(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: Durations.medium3,
                    padding: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(context).hoverColor,
                    width: leftpanel ? 70 : 0,
                    height: double.infinity,
                    child: leftpanel
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        leftpanel = !leftpanel;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.home,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      active = 0;
                                      answer = "";
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: active == 0
                                            ? Colors.green
                                            : Theme.of(context).splashColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.list_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        tophide && deviceType == "mobile"
                            ? const SizedBox()
                            : AnimatedContainer(
                                padding: const EdgeInsets.all(8.0),
                                duration: Durations.medium3,
                                height:
                                    tophide && deviceType == "mobile" ? 0 : 60,
                                color: Theme.of(context).hoverColor,
                                child: Center(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            leftpanel
                                                ? const SizedBox()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            leftpanel =
                                                                !leftpanel;
                                                          });
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .space_dashboard_rounded,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      widget.topic,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          widget.icondata,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            active == 0
                                                                ? "Sub Topics"
                                                                : widget.descriptions[
                                                                    active - 1],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Image.asset(
                                          "lib/assets/new degreen ic.png",
                                        ),
                                      ),
                                      Builder(builder: (context) {
                                        return IconButton(
                                          onPressed: () {
                                            Scaffold.of(context)
                                                .openEndDrawer();
                                          },
                                          icon: const Icon(Icons.folder),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                        Expanded(
                          child: answer == ""
                              ? SizedBox(
                                  child: SingleChildScrollView(
                                    child: deviceType == "mobile"
                                        ? Column(
                                            children: listertopics(
                                              context,
                                              'm',
                                              settingsProvider,
                                            ),
                                          )
                                        : Wrap(
                                            children: listertopics(
                                              context,
                                              'h',
                                              settingsProvider,
                                            ),
                                          ),
                                  ),
                                )
                              : answer == "loading"
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : answer.contains("Error")
                                      ? Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                margin:
                                                    const EdgeInsets.all(20),
                                                width: double.infinity,
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .network_check_outlined,
                                                      size: 80,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text(
                                                "Error Internet connection Required",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        int index = active - 1;
                                                        getContent(
                                                          type: 'reload',
                                                          index: index,
                                                          settingsProvider:
                                                              settingsProvider,
                                                        );
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text("reload"),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Wrap(
                                              alignment: WrapAlignment.end,
                                              children: [
                                                settingsProvider.settings
                                                            .language ==
                                                        "en"
                                                    ? boxbutton(
                                                        icon: isSpeaking
                                                            ? const Icon(
                                                                Icons
                                                                    .stop_rounded,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .volume_up_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        color: isSpeaking
                                                            ? Colors.red
                                                            : Colors.green,
                                                        onPressed: () {
                                                          if (!isSpeaking) {
                                                            speakstring = answer
                                                                .replaceAll(
                                                                    "#", "");
                                                            speakstring =
                                                                speakstring
                                                                    .replaceAll(
                                                                        "*",
                                                                        "");
                                                            speak(
                                                                textToConvert:
                                                                    speakstring,
                                                                context:
                                                                    context,
                                                                rate: settingsProvider
                                                                        .settings
                                                                        .fast
                                                                    ? kIsWeb
                                                                        ? 1.4
                                                                        : 0.6
                                                                    : kIsWeb
                                                                        ? 1
                                                                        : 0.5);
                                                          } else {
                                                            stopspeaking();
                                                          }
                                                        },
                                                      )
                                                    : const SizedBox(),
                                                boxbutton(
                                                  icon: const Icon(
                                                      Icons.menu_book_rounded,
                                                      color: Colors.white),
                                                  color: Colors.green,
                                                  onPressed: () async {
                                                    if (selectedText != "" &&
                                                        selectedText.length <=
                                                            45) {
                                                      setState(() {
                                                        wordmean = "loading";
                                                        littleload = "loading";
                                                      });
                                                      try {
                                                        var translated =
                                                            await selectedText
                                                                .translate(
                                                                    from:
                                                                        'auto',
                                                                    to: 'en');
                                                        wordmean =
                                                            translated.text;
                                                        wordmean =
                                                            await Topics()
                                                                .usingGermini(
                                                          what:
                                                              " give me short meaning of $wordmean represent it in a matured way",
                                                        );
                                                        if (!wordmean.contains(
                                                            "Error")) {
                                                          translated = await wordmean
                                                              .translate(
                                                                  to: settingsProvider
                                                                      .settings
                                                                      .language);
                                                          wordmean =
                                                              translated.text;
                                                        }
                                                        littleload = "done";
                                                      } on Exception {
                                                        littleload = "done";
                                                        wordmean =
                                                            "Error: network issue";
                                                      }
                                                      setState(() {});
                                                    } else if (selectedText
                                                            .length >
                                                        45) {
                                                      errormsg(
                                                          context: context,
                                                          error:
                                                              "More than the amount needed");
                                                    } else {
                                                      errormsg(
                                                          context: context,
                                                          error:
                                                              "Select a word to find its meaning");
                                                    }
                                                  },
                                                ),
                                                boxbutton(
                                                  icon: const Icon(
                                                      Icons.bookmark_add,
                                                      color: Colors.white),
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    if (selectedText != "") {
                                                      _titleController.text =
                                                          widget.topic;
                                                      _subtitleController.text =
                                                          activesubtitle;
                                                      _contentController.text =
                                                          selectedText;
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return SimpleDialog(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _titleController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    labelText:
                                                                        'Title',
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _subtitleController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    labelText:
                                                                        'Subtitle',
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _contentController,
                                                                  decoration: const InputDecoration(
                                                                      labelText:
                                                                          'Content'),
                                                                  maxLines: 5,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    CupertinoButton
                                                                        .filled(
                                                                  onPressed:
                                                                      saveItem,
                                                                  child:
                                                                      const Text(
                                                                          'Save'),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      errormsg(
                                                          context: context,
                                                          error:
                                                              "select sentences, words, descriptions to save for offline use");
                                                    }
                                                  },
                                                ),
                                                boxbutton(
                                                  icon: const Icon(
                                                      Icons.zoom_in_rounded,
                                                      color: Colors.white),
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    fontSize += 2.0;
                                                    children =
                                                        parseMarkdown(answer);
                                                    setState(() {});
                                                  },
                                                ),
                                                boxbutton(
                                                  icon: const Icon(
                                                      Icons.zoom_out_rounded,
                                                      color: Colors.white),
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    fontSize = 14;
                                                    children =
                                                        parseMarkdown(answer);
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SingleChildScrollView(
                                                    controller:
                                                        deviceType == "mobile"
                                                            ? scrollController
                                                            : tscrollController,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8,
                                                              left: 8,
                                                              right: 8),
                                                      child: children,
                                                    ),
                                                  ),
                                                  wordmean == ""
                                                      ? const SizedBox()
                                                      : Container(
                                                          width: deviceType ==
                                                                  "mobile"
                                                              ? deviceWidth -
                                                                  120
                                                              : deviceWidth / 2,
                                                          height: deviceHeight -
                                                              300,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Theme.of(
                                                                    context)
                                                                .scaffoldBackgroundColor,
                                                            border: Border.all(
                                                              width: 5,
                                                              color: Theme.of(
                                                                      context)
                                                                  .hoverColor,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  selectedText,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ),
                                                              const Divider(
                                                                thickness: 3,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .splashColor,
                                                                  ),
                                                                  child: littleload ==
                                                                          "loading"
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        )
                                                                      : wordmean
                                                                              .contains("Error")
                                                                          ? const Center(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(CupertinoIcons.wifi_exclamationmark),
                                                                                  Text("No Internet Connection")
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : SingleChildScrollView(
                                                                              child: parseMarkdown(wordmean),
                                                                            ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (outfocus ==
                                                                            true) {
                                                                          selectedText =
                                                                              "";
                                                                        }
                                                                        wordmean =
                                                                            "";
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.red,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        child:
                                                                            const Text(
                                                                          "close",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 200, bottom: 12),
                color: Colors.transparent,
                width: leftpanel
                    ? _isDescriptionVisible
                        ? 270
                        : 70
                    : 0,
                height: double.infinity,
                child: leftpanel
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: List.generate(
                            widget.descriptions.length,
                            (index) => SizedBox(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      getContent(
                                        type: 'main',
                                        index: index,
                                        settingsProvider: settingsProvider,
                                      );
                                    },
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onHover: (value) {
                                      setState(() {
                                        if (value) {
                                          _isDescriptionVisible = true;
                                        } else {
                                          _isDescriptionVisible = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: index + 1 >= 10
                                          ? const EdgeInsets.all(15)
                                          : const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 15,
                                            ),
                                      margin: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: active - 1 == index
                                            ? Colors.green
                                            : index % 2 == 0
                                                ? Theme.of(context).hoverColor
                                                : Theme.of(context).splashColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text((index + 1).toString()),
                                    ),
                                  ),
                                  _isDescriptionVisible
                                      ? Container(
                                          margin: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          width: 200,
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).splashColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                spreadRadius: 2,
                                              )
                                            ],
                                          ),
                                          child: Text(
                                            widget.descriptions[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(int index) {
    List<String> titlesplitter = _filteredItems[index].title.split("-::::-");

    String title = titlesplitter[0];
    String subtitle = titlesplitter[1];
    final titleController = TextEditingController(text: title),
        subtitleController = TextEditingController(text: subtitle),
        contentController =
            TextEditingController(text: _filteredItems[index].content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                final title =
                    "${titleController.text}-::::-${subtitleController.text}";
                _updateContent(index, title, titleController.text,
                    subtitleController.text, contentController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Container boxbutton({
    required Icon icon,
    required Color color,
    required void Function()? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }

  Widget parseMarkdown(String data) {
    List<TextSpan> textspans = [];
    List<String> lines = data.split('\n');
    String selectiondata = "";
    String inhere = "";

    for (String line in lines) {
      if (line.startsWith('# ')) {
        inhere = "${line.substring(2)}\n";
        textspans.add(
          TextSpan(
            text: inhere,
            style: TextStyle(
              fontSize: fontSize * 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        selectiondata += inhere;
      } else if (line.startsWith('## ')) {
        inhere = "${line.substring(3)}\n";
        textspans.add(
          TextSpan(
            text: inhere,
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        selectiondata += inhere;
      } else if (line.startsWith('### ')) {
        inhere = "${line.substring(4)}\n";
        textspans.add(
          TextSpan(
            text: inhere,
            style: TextStyle(
              fontSize: fontSize * 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        selectiondata += inhere;
      } else {
        // for bolding
        // line = line.
        if (line.contains("**")) {
          textspans.add(boldText(line)[0]);
          inhere = boldText(line)[1];
          selectiondata += inhere;
        } else if (line.contains("*")) {
          textspans.add(italicText(line)[0]);
          inhere = italicText(line)[1];
          selectiondata += inhere;
        } else {
          inhere = "$line\n";
          textspans.add(
            TextSpan(
              text: inhere,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          );
          selectiondata += inhere;
        }
      }
    }
    Widget markdownedit = SelectableText.rich(
      TextSpan(children: textspans),
      onSelectionChanged: (TextSelection selection, SelectionChangedCause? _) {
        if (selection.baseOffset != selection.extentOffset) {
          final start = math.min(selection.baseOffset, selection.extentOffset);
          final end = math.max(selection.baseOffset, selection.extentOffset);
          selectedText = selectiondata.substring(start, end);
          // selectedText = selectiondata.substring(
          //     selection.baseOffset, selection.extentOffset);
          outfocus = false;
          setState(() {});
        } else if (_ == SelectionChangedCause.tap) {
          outfocus = true;
          if (wordmean == "" && littleload != "loading") {
            selectedText = "";
          }
          setState(() {});
        }
      },
    );
    return markdownedit;
  }

//bolding
  List<dynamic> boldText(String input) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    Iterable<RegExpMatch> matches = exp.allMatches(input);
    String inherec = "";

    int currentIndex = 0;
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            children: [
              italicText(
                "${input.substring(currentIndex, match.start)}......",
              )[0],
            ],
          ),
        );
      }
      if (match.end == input.length) {
        spans.add(TextSpan(
          text: "${match.group(1)!}\n",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      }
      currentIndex = match.end;
    }

    if (currentIndex < input.length) {
      spans.add(
        TextSpan(
          children: [
            italicText("${input.substring(currentIndex)}\n")[0],
          ],
        ),
      );
    }

    for (var elem in spans) {
      if (elem.children == null) {
        inherec += elem.text!;
      } else {
        for (var inelem in elem.children!) {
          inherec += inelem.toPlainText();
        }
      }
    }
    return [
      TextSpan(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: fontSize,
        ),
        children: spans,
      ),
      inherec
    ];
  }

//italicizing

  List<dynamic> italicText(String input) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*(.*?)\*');
    Iterable<RegExpMatch> matches = exp.allMatches(input);
    String ininhere = "";

    int currentIndex = 0;
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: input.substring(currentIndex, match.start)));
      }
      if (match.end == input.length) {
        spans.add(TextSpan(
          text: match.group(1)!.contains("......") ||
                  match.group(1)!.contains("\n")
              ? match.group(1)!.contains("......")
                  ? "${match.group(1)!}\n".replaceAll("......", "")
                  : "${match.group(1)!}\n".replaceFirst("\n", "")
              : "${match.group(1)!}\n",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else {
        spans.add(
          TextSpan(
            text: match.group(1)!,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      currentIndex = match.end;
    }

    if (currentIndex < input.length) {
      if (input.contains("......") || input.contains("\n")) {
        input = input.replaceAll("......", "");
        input = input.replaceAll("\n", "");
        input = input.substring(currentIndex);
        if (input.length > 7) input = "$input\n";
      } else {
        input = "${input.substring(currentIndex)}\n";
      }
      spans.add(TextSpan(text: input));
    }
    for (var elem in spans) {
      ininhere += elem.text!;
    }
    return [
      TextSpan(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: fontSize,
        ),
        children: spans,
      ),
      ininhere
    ];
  }

  List<Widget> listertopics(
    BuildContext context,
    String s,
    settingsProvider,
  ) {
    return List.generate(
      widget.descriptions.length,
      (index) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            getContent(
              type: 'main',
              index: index,
              settingsProvider: settingsProvider,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            width: s == "m" ? double.infinity : 300,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? Theme.of(context).hoverColor
                  : Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                right: BorderSide(
                  color: Colors.green,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: index + 1 >= 10
                      ? const EdgeInsets.all(15)
                      : const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    widget.descriptions[index],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getContent({
    required String type,
    required int index,
    required SettingsProvider settingsProvider,
  }) async {
    setState(() {
      answer = "loading";
    });
    activesubtitle = widget.descriptions[index];
    answer = await Topics().usingGermini(
      what:
          " give me the $activesubtitle of ${widget.topic} represent it in a matured way",
    );
    if (type != "reload") active = index + 1;
    if (!answer.contains("Error")) {
      var translated =
          await answer.translate(to: settingsProvider.settings.language);
      answer = translated.text;
      children = parseMarkdown(answer);
    }

    setState(() {});
  }
}
