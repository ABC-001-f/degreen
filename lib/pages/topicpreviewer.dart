// ignore_for_file: use_build_context_synchronously

import 'package:degreen/topics.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:popover/popover.dart';

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
  bool leftpanel = false;
  late ScrollController scrollController;
  ScrollController tscrollController = ScrollController();
  double scrollyoffset = 0;
  bool tophide = false;
  bool _isDescriptionVisible = false;
  late ScrollController _scrollController;
  String answer = "";
  String speakstring = "";
  bool isSpeaking = false;
  int active = 0;
  double fontSize = 14.0;
  FlutterTts flutterTts = FlutterTts();
  String? maleVoice;
  Widget children = const SizedBox();
  void increaseFontSize() {
    setState(() {
      fontSize += 2.0;
    });
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
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String deviceType = "";
    if (screenWidth >= 1200) {
      deviceType = 'huge';
    } else if (screenWidth >= 700) {
      deviceType = 'tablet';
    } else {
      deviceType = 'mobile';
    }

    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: Scaffold(
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      leftpanel = !leftpanel;
                                    });
                                  },
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
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
                                InkWell(
                                  onTap: () {
                                    active = 0;
                                    answer = "";
                                    setState(() {});
                                  },
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
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
                        tophide
                            ? const SizedBox()
                            : AnimatedContainer(
                                padding: const EdgeInsets.all(8.0),
                                duration: Durations.medium3,
                                height: tophide ? 0 : 60,
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
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          leftpanel =
                                                              !leftpanel;
                                                        });
                                                      },
                                                      hoverColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                      child: const Icon(
                                                        Icons
                                                            .space_dashboard_rounded,
                                                        color: Colors.grey,
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
                                        child: const Icon(
                                          Icons.energy_savings_leaf,
                                          color: Colors.green,
                                        ),
                                      )
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
                                      : Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 8, right: 8),
                                              child: SingleChildScrollView(
                                                controller:
                                                    deviceType == "mobile"
                                                        ? scrollController
                                                        : tscrollController,
                                                child: children,
                                              ),
                                            ),
                                            tophide
                                                ? const SizedBox()
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      settingsProvider.settings
                                                                  .language ==
                                                              "en"
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                color: isSpeaking
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
                                                              ),
                                                              child: IconButton(
                                                                onPressed: () {
                                                                  if (!isSpeaking) {
                                                                    speakstring =
                                                                        answer.replaceAll(
                                                                            "#",
                                                                            "");
                                                                    speakstring =
                                                                        speakstring.replaceAll(
                                                                            "*",
                                                                            "");
                                                                    speak(
                                                                        textToConvert:
                                                                            speakstring,
                                                                        context:
                                                                            context,
                                                                        rate: settingsProvider.settings.fast
                                                                            ? 0.6
                                                                            : 0.5);
                                                                  } else {
                                                                    stopspeaking();
                                                                  }
                                                                },
                                                                icon: isSpeaking
                                                                    ? const Icon(
                                                                        Icons
                                                                            .stop_rounded)
                                                                    : const Icon(
                                                                        Icons
                                                                            .volume_up_rounded),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: Colors.green,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            fontSize += 2.0;
                                                            children =
                                                                parseMarkdown(
                                                                    answer);
                                                            setState(() {});
                                                          },
                                                          icon: const Icon(
                                                              Icons.add),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: Colors.green,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            fontSize = 14;
                                                            children =
                                                                parseMarkdown(
                                                                    answer);
                                                            setState(() {});
                                                          },
                                                          icon: const Icon(
                                                            Icons.remove,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
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
    print(selectiondata.length);
    print(data.length);
    Widget markdownedit = SelectableText.rich(
      TextSpan(children: textspans),
      onSelectionChanged: (TextSelection selection, _) {
        if (selection.baseOffset != selection.extentOffset) {
          String selectedText = selectiondata.substring(
              selection.baseOffset, selection.extentOffset);
          print('Selected Text: $selectedText');
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
      (index) => InkWell(
        onTap: () async {
          getContent(
            type: 'main',
            index: index,
            settingsProvider: settingsProvider,
          );
        },
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
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
    answer = await Topics().usingGermini(
      what:
          " give me the ${widget.descriptions[index]} of ${widget.topic} represent it in a matured way",
    );
    print(answer);
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
