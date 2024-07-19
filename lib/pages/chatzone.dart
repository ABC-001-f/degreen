// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:degreen/topics.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class ChatZone extends StatefulWidget {
  final String reply;
  const ChatZone({
    super.key,
    required this.reply,
  });

  @override
  State<ChatZone> createState() => _ChatZoneState();
}

class _ChatZoneState extends State<ChatZone> {
  TextEditingController chatController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController searchinController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map> filteredItems = [];
  FlutterTts flutterTts = FlutterTts();
  String whichactive = "msg", speakstring = "", _status = "checking ...";
  final String _url = 'https://jsonplaceholder.typicode.com/posts/1';
  //msg or selectmode or search or package
  double fontSize = 14.0;
  int replyid = 0, respondreplyid = 0;
  String response = "";
  Widget children = const SizedBox();
  List<dynamic> chatsandpackages = [];
  List selectedchatbox = [];
  List<Map<String, dynamic>> chats = [];
  List<dynamic> packages = [];
  List<Map<String, dynamic>> filteredChats = [];

  late Timer _timer;
  static const _duration = Duration(milliseconds: 500);

  bool searchactive = false,
      rightbar = false,
      replyactivated = false,
      activesearch = false,
      activesend = false,
      checkingpromptdone = true,
      endreachedinscrol = true,
      loadingspeachall = false,
      isSpeaking = false;
  String replyingcontent = "";
  @override
  void initState() {
    super.initState();
    _startPeriodicRequest();
    _loadContent();
    _loadChats(del: false);
    _searchFocusNode.addListener(_handleSearchFocus);
    searchinController.addListener(filterItems);
  }

  @override
  void dispose() {
    searchinController.removeListener(filterItems);
    searchController.dispose();
    _timer.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startPeriodicRequest() {
    if (!activesend) {
      _timer = Timer.periodic(_duration, (Timer timer) async {
        try {
          final response = await http.get(Uri.parse(_url));
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                _status = 'Available now';
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _status = 'Offline now';
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _status = 'Offline now';
            });
          }
        }
      });
    }
  }

  void _loadContent() {
    setState(() {
      filteredItems = [
        {
          "id": 1,
          "title": "Agro based indurstries",
          "chatids": [2, 1],
          "createddate": "12-2-2024 : 4:00pm",
          "modefieddate": "12-2-2025 : 4:00pm",
        }
      ];
      _sortContent();
    });
  }

  void _sortContent() {
    setState(() {
      filteredItems
          .sort((a, b) => a['modefieddate'].compareTo(b['modefieddate']));
    });
  }

  void filterItems() {
    String query = searchinController.text.toLowerCase();
    _loadContent();
    setState(() {
      filteredItems = filteredItems.where((item) {
        return item['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<String> _getChatsFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'chats.json');
  }

  Future<void> _loadChats({required bool del}) async {
    chatsandpackages = [];
    final filePath = await _getChatsFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      final jsonContent = jsonDecode(content);
      setState(() {
        chats = List<Map<String, dynamic>>.from(jsonContent['chats']);
        packages = jsonContent['packages'];
      });
    } else {
      await file.create();
      final initialContent = jsonEncode({'chats': [], 'packages': []});
      await file.writeAsString(initialContent);
    }
    setState(() {
      filteredChats = chats;
    });
    displayingchats();
    if (!del) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  void displayingchats() {
    chatsandpackages = [];
    for (var element in filteredChats) {
      chatsandpackages.add(element);
    }
  }

  Future<void> _saveChats() async {
    final filePath = await _getChatsFilePath();
    final file = File(filePath);
    final updatedContent = jsonEncode({'chats': chats, 'packages': packages});
    await file.writeAsString(updatedContent);
  }

  Future<void> addChat({
    required String msg,
    required String replyid,
    required String resreplyid,
    required String respond,
  }) async {
    final newChatId = chats.isNotEmpty ? chats.last['chatid'] + 1 : 1;
    final newChat = {
      'type': 'chat',
      'chatid': newChatId,
      'replyto': replyid,
      'chatcontent': msg,
      'dateofchat': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'respondreplyid': resreplyid,
      'respond': respond
    };

    setState(() {
      chats.add(newChat);
    });
    _saveChats();
    _loadChats(del: false);
  }

  Future<void> _deleteChat(int chatId) async {
    setState(() {
      chats.removeWhere((chat) => chat['chatid'] == chatId);
    });
    await _saveChats();
    await _loadChats(del: true);
  }

  Future<void> clearAllChats() async {
    chatsandpackages = [];
    filteredChats = [];
    final filePath = await _getChatsFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    chats = [];
    packages = [];
    setState(() {});
  }

  void scrollToBottom() {
    if (chatsandpackages.isNotEmpty) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      searchController.addListener(_handleSearch);
    } else {
      searchController.removeListener(_handleSearch);
    }
  }

  void _handleSearch() {
    if (searchController.text.isEmpty) {
      filteredChats = chats;
    } else {
      filteredChats = chats.where((chat) {
        return chat['chatcontent']
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }
    displayingchats();
    setState(() {});
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

  Future<void> stopspeaking() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String deviceType = "";
    if (screenWidth >= 600) {
      deviceType = 'huge';
    } else {
      deviceType = 'mobile';
    }
    final settingsProvider = Provider.of<SettingsProvider>(context);
    chatController.addListener(
      () {
        if (chatController.text != "" && chatController.text != " ") {
          activesend = true;
        } else {
          activesend = false;
        }
        setState(() {});
      },
    );
    searchController.addListener(
      () {
        if (searchController.text != "" && searchController.text != " ") {
          activesearch = true;
          _handleSearch();
        } else {
          activesearch = false;
        }
        setState(() {});
      },
    );
    scrollController.addListener(
      () {
        if (scrollController.offset ==
            scrollController.position.minScrollExtent) {
          endreachedinscrol = true;
        } else {
          endreachedinscrol = false;
        }
        setState(() {});
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              "lib/assets/new degreen ic.png",
              width: 60,
              height: 60,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Degreen"),
                Text(
                  _status,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("Settings"),
                  contentPadding: const EdgeInsets.all(12),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(300),
                                color: Theme.of(context).hoverColor),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(300),
                              child: Center(
                                child: Image.asset(
                                  "lib/assets/new degreen ic.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Give Me A Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Can I Call You',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton.filled(
                        child: const Text("submit"), onPressed: () {}),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.settings_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(chatsandpackages.length > 1
                          ? 'Delete Chats ?'
                          : 'Delete Chat ?'),
                      content: Text(chatsandpackages.length > 1
                          ? "This will delete the sent and responds of all these chats"
                          : "This will delete the sent and responds of this chat"),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text('Proceed'),
                          onPressed: () async {
                            Navigator.pop(context);
                            await clearAllChats();
                            chatsandpackages = [];
                          },
                        ),
                      ],
                    );
                  },
                );
                setState(() {});
              },
              icon: const Icon(Icons.delete),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        child: drawercustom(deviceType: deviceType),
      ),
      body: SizedBox(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).hoverColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    focusNode: _searchFocusNode,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Search Chat",
                                    ),
                                  ),
                                ),
                                actionbuttons(
                                  context: context,
                                  child: activesearch
                                      ? const Icon(Icons.close)
                                      : const Icon(Icons.search_rounded),
                                  onTap: () {
                                    if (activesearch) {
                                      searchController.text = "";
                                    }
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Builder(builder: (context) {
                                  return actionbuttons(
                                    context: context,
                                    child: const Icon(
                                        CupertinoIcons.envelope_fill),
                                    onTap: () {
                                      deviceType == "huge"
                                          ? setState(() {
                                              rightbar = true;
                                            })
                                          : Scaffold.of(context)
                                              .openEndDrawer();
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          Expanded(
                            child: chatsandpackages.isEmpty
                                ? Center(
                                    child: Lottie.asset(
                                      'lib/assets/chatintro.json',
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      SingleChildScrollView(
                                        controller: scrollController,
                                        reverse: true,
                                        child: Column(
                                          children: List.generate(
                                            chatsandpackages.length,
                                            (index) {
                                              String replycontent = "";
                                              if (chatsandpackages[index]
                                                      ['replyto'] !=
                                                  "none") {
                                                for (var i = 0;
                                                    i < chats.length;
                                                    i++) {
                                                  if (chats[i]['chatid'] ==
                                                      int.parse(
                                                          chatsandpackages[
                                                                  index]
                                                              ['replyto'])) {
                                                    replycontent =
                                                        chats[i]['chatcontent'];
                                                  }
                                                }
                                              }

                                              // print(
                                              //     "sender reply ----------- ${chatsandpackages[index]['replyto']} -- $replycontent");

                                              String resreplycontent = "";
                                              if (chatsandpackages[index]
                                                      ['respondreplyid'] !=
                                                  "none") {
                                                for (var i = 0;
                                                    i < chats.length;
                                                    i++) {
                                                  if (chats[i]['chatid'] ==
                                                      int.parse(chatsandpackages[
                                                              index]
                                                          ['respondreplyid'])) {
                                                    resreplycontent =
                                                        chats[i]['respond'];
                                                  }
                                                }
                                              }
                                              // print(
                                              //     "reciever reply ----------- ${chatsandpackages[index]['respondreplyid']} -- $resreplycontent");
                                              // print(
                                              //     "================================");
                                              //'chatid': newChatId,
                                              // 'replyto': replyid,
                                              // 'chatcontent': msg,
                                              // 'dateofchat': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                              // 'respondreplyid': resreplyid,
                                              // 'respond': respond
                                              if (chatsandpackages[index]
                                                      ['type'] ==
                                                  "chat") {
                                                return Column(
                                                  children: [
                                                    sender(
                                                      msgcontent:
                                                          chatsandpackages[
                                                                  index]
                                                              ['chatcontent'],
                                                      onTap: () {
                                                        if (selectedchatbox
                                                            .contains(
                                                                chatsandpackages[
                                                                        index][
                                                                    'chatid'])) {
                                                          for (var ine = 0;
                                                              ine <
                                                                  selectedchatbox
                                                                      .length;
                                                              ine++) {
                                                            if (selectedchatbox[
                                                                    ine] ==
                                                                chatsandpackages[
                                                                        index][
                                                                    'chatid']) {
                                                              selectedchatbox
                                                                  .removeAt(
                                                                      ine);
                                                            }
                                                          }
                                                        } else {
                                                          selectedchatbox.add(
                                                              chatsandpackages[
                                                                      index]
                                                                  ['chatid']);
                                                        }
                                                        if (selectedchatbox
                                                            .isEmpty) {
                                                          selectedchatbox = [];
                                                          whichactive = "msg";
                                                        } else {
                                                          whichactive =
                                                              "select";
                                                        }
                                                        setState(() {});
                                                      },
                                                      replycontent:
                                                          replycontent == ""
                                                              ? resreplycontent
                                                              : replycontent,
                                                      replyin: replycontent ==
                                                                  "" &&
                                                              resreplycontent ==
                                                                  ""
                                                          ? false
                                                          : true,
                                                      datetime:
                                                          chatsandpackages[
                                                                  index]
                                                              ['dateofchat'],
                                                      delTap: () {
                                                        deletingchat(
                                                            chatid:
                                                                chatsandpackages[
                                                                        index]
                                                                    ['chatid']);
                                                        setState(() {});
                                                      },
                                                      chatid: chatsandpackages[
                                                          index]['chatid'],
                                                      settingsProvider:
                                                          settingsProvider,
                                                      noresponse: chatsandpackages[
                                                                      index]
                                                                  ['respond'] ==
                                                              ""
                                                          ? true
                                                          : false,
                                                      toai: chatsandpackages[
                                                                      index][
                                                                  'respondreplyid'] !=
                                                              "none"
                                                          ? true
                                                          : false,
                                                    ),
                                                    chatsandpackages[index]
                                                                ['respond'] ==
                                                            ""
                                                        ? const SizedBox()
                                                        : reciever(
                                                            msgcontent:
                                                                chatsandpackages[
                                                                        index]
                                                                    ['respond'],
                                                            onTap: () {
                                                              if (selectedchatbox.contains(
                                                                  chatsandpackages[
                                                                          index]
                                                                      [
                                                                      'chatid'])) {
                                                                for (var ine =
                                                                        0;
                                                                    ine <
                                                                        selectedchatbox
                                                                            .length;
                                                                    ine++) {
                                                                  if (selectedchatbox[
                                                                          ine] ==
                                                                      chatsandpackages[
                                                                              index]
                                                                          [
                                                                          'chatid']) {
                                                                    selectedchatbox
                                                                        .removeAt(
                                                                            ine);
                                                                  }
                                                                }
                                                              } else {
                                                                selectedchatbox.add(
                                                                    chatsandpackages[
                                                                            index]
                                                                        [
                                                                        'chatid']);
                                                              }
                                                              if (selectedchatbox
                                                                  .isEmpty) {
                                                                selectedchatbox =
                                                                    [];
                                                                whichactive =
                                                                    "msg";
                                                              } else {
                                                                whichactive =
                                                                    "select";
                                                              }
                                                              setState(() {});
                                                            },
                                                            replycontent:
                                                                replycontent,
                                                            replyin:
                                                                replycontent ==
                                                                        ""
                                                                    ? false
                                                                    : true,
                                                            chatid:
                                                                chatsandpackages[
                                                                        index]
                                                                    ['chatid'],
                                                            settingsProvider:
                                                                settingsProvider,
                                                          ),
                                                  ],
                                                );
                                              } else {
                                                //package

                                                return packagerdesign();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      !endreachedinscrol
                                          ? IconButton(
                                              onPressed: () => scrollToBottom(),
                                              icon: const Icon(
                                                  CupertinoIcons.chevron_down),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            child: Column(
                              children: [
                                replyactivated
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              replyid > 0
                                                  ? const Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                              Icons.person),
                                                        ),
                                                        Text(
                                                            "Replying to Yourself"),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Image.asset(
                                                          "lib/assets/new degreen ic.png",
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                        const Text(
                                                            "Replying to Degreen"),
                                                      ],
                                                    ),
                                              IconButton(
                                                onPressed: () {
                                                  replyactivated = false;
                                                  replyingcontent = "";
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                    Icons.close_rounded),
                                              )
                                            ],
                                          ),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minHeight: 10,
                                              maxHeight: 150,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              width: double.infinity,
                                              margin: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .splashColor,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: SingleChildScrollView(
                                                child: parseMarkdown(
                                                    replyingcontent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: whichactive != "msg"
                                      ? 300
                                      : double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: whichactive == "msg"
                                      ? msging(
                                          context,
                                          holder: replyactivated
                                              ? "Reply"
                                              : "Talk to me ...",
                                          settingsProvider: settingsProvider,
                                        )
                                      : whichactive == "select"
                                          ? selecting(context,
                                              settingsProvider:
                                                  settingsProvider)
                                          : whichactive == "search"
                                              ? const SizedBox()
                                              : msging(
                                                  context,
                                                  holder: replyactivated
                                                      ? "Reply in package"
                                                      : "Add more chats to package",
                                                  settingsProvider:
                                                      settingsProvider,
                                                ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text("Powered By Gemini"),
                ],
              ),
            ),
            deviceType == "huge" && rightbar == true
                ? Container(
                    width: 320,
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).hoverColor,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: drawercustom(deviceType: deviceType),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  CustomScrollView drawercustom({
    required String deviceType,
  }) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => deviceType != "huge"
                  ? Navigator.of(context).pop()
                  : setState(() {
                      rightbar = false;
                    }),
              child: const Icon(Icons.chevron_left),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Packages"),
              searchactive
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      height: 50,
                      child: TextField(
                        controller: searchinController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : Text(
                      filteredItems.length > 1
                          ? "${filteredItems.length} items"
                          : "${filteredItems.length} item",
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
        filteredItems.isEmpty
            ? const SliverFillRemaining(
                child: Center(child: Text('No items found')),
              )
            : SliverList.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final content = filteredItems[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).canvasColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                content['title'],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Extract Package ?'),
                                              content: Text(
                                                  "Extract all the content of ${content['title']}"),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Proceed'),
                                                  onPressed: () {
                                                    //extract function
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                          CupertinoIcons.tray_arrow_up_fill),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Delete Package ?'),
                                              content: Text(
                                                  "This will delete ${content['title']} package and all it's content \n Do you prefer to "),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Extract'),
                                                  onPressed: () {
                                                    //extract function
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Proceed'),
                                                  onPressed: () {
                                                    //delete function
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 250,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context).hoverColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hoverColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                    ),
                                    width: 160,
                                    child:
                                        const Text("hello world i am good..."),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                    ),
                                    width: 160,
                                    child:
                                        const Text("hello world i am good..."),
                                  ),
                                ],
                              ),
                              const Expanded(
                                child: SizedBox(),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).splashColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: 160,
                                child: Center(
                                  child: Text(content['chatids'].length - 1 > 1
                                      ? "and ${content['chatids'].length - 1} others"
                                      : "and ${content['chatids'].length - 1} other"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date Created :\n ${content['createddate']}"),
                            Divider(
                              color: Theme.of(context).hoverColor,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Date Modified :\n ${content['modefieddate']}"),
                                ElevatedButton(
                                  child: const Text("view"),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              )
      ],
    );
  }

  Row selecting(BuildContext context,
      {required SettingsProvider settingsProvider}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        actionbuttons(
          context: context,
          child: const Icon(Icons.delete),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(selectedchatbox.length > 1
                      ? 'Delete Chats ?'
                      : 'Delete Chat ?'),
                  content: Text(selectedchatbox.length > 1
                      ? "This will delete the sent and responds of all these chats"
                      : "This will delete the sent and responds of this chat"),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                        selectedchatbox = [];
                      },
                    ),
                    TextButton(
                      child: const Text('Proceed'),
                      onPressed: () async {
                        Navigator.pop(context);
                        for (var word in selectedchatbox) {
                          await _deleteChat(word);
                          selectedchatbox = [];
                        }
                      },
                    ),
                  ],
                );
              },
            );

            whichactive = "msg";
            setState(() {});
          },
        ),
        actionbuttons(
          context: context,
          child: const Icon(CupertinoIcons.envelope_open_fill),
          onTap: () {},
        ),
        actionbuttons(
          context: context,
          child: loadingspeachall
              ? Lottie.asset(
                  'lib/assets/typing.json',
                  height: 15,
                  fit: BoxFit.contain,
                )
              : isSpeaking
                  ? const Icon(
                      Icons.stop_rounded,
                      color: Colors.red,
                    )
                  : const Icon(Icons.volume_up_rounded),
          onTap: () async {
            setState(() {
              loadingspeachall = true;
            });
            selectedchatbox.sort();
            String selectedtospeak = "";
            for (var word in selectedchatbox) {
              var chat = chats.where((chat) => chat['chatid'] == word).toList();
              var whattosay = "On ${chat[0]['dateofchat']} \n ";
              String checkques = await trainer(
                settingsProvider: settingsProvider,
                what: "is this a question? : ${chat[0]['chatcontent']}",
                how: "I need a yes or no anwser only ,",
              );
              whattosay += checkques.contains("es")
                  ? "You asked ${chat[0]['chatcontent']}"
                  : "You said ${chat[0]['chatcontent']}";
              if (chat[0]['respond'] != "") {
                String response = chat[0]['respond'].replaceAll("*", "");
                response = response.replaceAll("#", "");
                checkques = await trainer(
                  settingsProvider: settingsProvider,
                  what: "is this a question? : $response",
                  how: "I need a yes or no anwser only ,",
                );
                whattosay += checkques.contains("es")
                    ? " then I asked  $response"
                    : " then I answered  $response";
                selectedtospeak += "$whattosay \n";
              } else {
                whattosay += " and I didn't answer due to network issues";
                selectedtospeak += "$whattosay \n";
              }
            }

            setState(() {
              loadingspeachall = false;
              response = "";
            });

            if (!isSpeaking) {
              speak(
                  textToConvert: selectedtospeak,
                  context: context,
                  rate: settingsProvider.settings.fast
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
        ),
        actionbuttons(
          context: context,
          child: const Icon(Icons.copy),
          onTap: () async {
            String selectedtocopy = "";
            for (var word in selectedchatbox) {
              var chat = chats.where((chat) => chat['chatid'] == word).toList();
              selectedtocopy += "${chat[0]['chatcontent']} \n";
              String response = chat[0]['respond'].replaceAll("*", "");
              response = response.replaceAll("#", "");
              selectedtocopy += "$response \n";
            }

            await FlutterClipboard.copy(selectedtocopy);
            errormsg(context: context, error: "Item Copied");

            selectedchatbox = [];
            whichactive = "msg";
            setState(() {});
          },
        ),
        actionbuttons(
          context: context,
          child: Text(
            selectedchatbox.length.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            selectedchatbox = [];
            whichactive = "msg";
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget actionbuttons({
    required BuildContext context,
    required Widget child,
    required void Function()? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Row msging(
    BuildContext context, {
    required String holder,
    required SettingsProvider settingsProvider,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            maxLines: 7,
            minLines: 1,
            controller: chatController,
            cursorWidth: 18,
            cursorRadius: const Radius.circular(30),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: holder,
            ),
          ),
        ),
        !checkingpromptdone
            ? typing()
            : MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    if (chatController.text != "" &&
                        chatController.text != " ") {
                      setState(() {
                        checkingpromptdone = false;
                      });
                      if (replyactivated) {
                        int whichid = replyid == 0 ? respondreplyid : replyid;
                        var chat = chats
                            .where((chat) => chat['chatid'] == whichid)
                            .toList();
                        String whatto = replyid == 0
                            ? chat[0]['respond']
                            : chat[0]['chatcontent'];
                        String checkingstuff = await trainer(
                          settingsProvider: settingsProvider,
                          what:
                              "is '${chatController.text}' referencing to ' $whatto ' ",
                          how: "i need only a yes or no answer",
                        );
                        if (checkingstuff
                            .toLowerCase()
                            .contains("error----error-error--")) {
                          uploadnoresponse(
                            msg: chatController.text,
                            replyid: replyid == 0 ? 0 : replyid,
                            resreplyid:
                                respondreplyid == 0 ? 0 : respondreplyid,
                          );
                        } else {
                          if (checkingstuff.toLowerCase().contains("yes")) {
                            checkingstuff = await Topics().usingGermini(
                              what:
                                  "answer '${chatController.text}' referencing to ' $whatto ' in a matured way",
                            );
                          } else {
                            checkingstuff = await trainer(
                              settingsProvider: settingsProvider,
                              what:
                                  "is '${chatController.text}' attempting to correct or improve ' $whatto ' ",
                              how: "i need only a yes or no answer",
                            );
                            if (checkingstuff.toLowerCase().contains("yes")) {
                              checkingstuff = await Topics().usingGermini(
                                what:
                                    "pretented as if i used '${chatController.text}' to correct and improve your knowledge based on ' $whatto ' then reply in a matured way",
                              );
                            } else {
                              checkingstuff = await trainer(
                                settingsProvider: settingsProvider,
                                what:
                                    "is '${chatController.text}' attempting to summarize ' $whatto ' ",
                                how: "i need only a yes or no answer",
                              );
                              if (checkingstuff.toLowerCase().contains("yes")) {
                                checkingstuff = await Topics().usingGermini(
                                  what:
                                      "pretend that you just taught me ' $whatto ' then i said '${chatController.text}'  reply to me in a matured way",
                                );
                              } else {
                                checkingstuff = await trainer(
                                  settingsProvider: settingsProvider,
                                  what:
                                      "is '${chatController.text}' attempting to give feedback on ' $whatto ' ",
                                  how: "i need only a yes or no answer",
                                );
                                if (checkingstuff
                                    .toLowerCase()
                                    .contains("yes")) {
                                  checkingstuff = await Topics().usingGermini(
                                    what:
                                        "pretend that you just recieved '${chatController.text}' as feedback regarding to ' $whatto ' and reply  in a matured way",
                                  );
                                } else {
                                  checkingstuff = await trainer(
                                    settingsProvider: settingsProvider,
                                    what:
                                        "is '${chatController.text}' attempting to express curiosity on ' $whatto ' ",
                                    how: "i need only a yes or no answer",
                                  );
                                  if (checkingstuff
                                      .toLowerCase()
                                      .contains("yes")) {
                                    checkingstuff = await Topics().usingGermini(
                                      what:
                                          "someone is expressing curiosity by telling you '${chatController.text}' regarding to ' $whatto ' reply in a matured way",
                                    );
                                  } else {
                                    checkingstuff = await trainer(
                                      settingsProvider: settingsProvider,
                                      what:
                                          "is '${chatController.text}' telling you that you forgot to say something about ' $whatto ' ",
                                      how: "i need only a yes or no answer",
                                    );
                                    if (checkingstuff
                                        .toLowerCase()
                                        .contains("yes")) {
                                      checkingstuff =
                                          await Topics().usingGermini(
                                        what:
                                            "pretend as if you forgot to tell me about ' $whatto ' then reply in a matured way",
                                      );
                                    } else {
                                      checkingstuff = await trainer(
                                        settingsProvider: settingsProvider,
                                        what:
                                            "is '${chatController.text}' telling you that it is confused or need more clarifications on ' $whatto ' ",
                                        how: "i need only a yes or no answer",
                                      );
                                      if (checkingstuff
                                          .toLowerCase()
                                          .contains("yes")) {
                                        checkingstuff =
                                            await Topics().usingGermini(
                                          what:
                                              "someone needs your help by asking you '${chatController.text}' regarding to ' $whatto ' reply in a matured way",
                                        );
                                      } else {
                                        checkingstuff =
                                            await Topics().usingGermini(
                                          what: chatController.text,
                                        );
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          uploadwithresponse(
                            msg: chatController.text,
                            replyid: replyid == 0 ? 0 : replyid,
                            resreplyid:
                                respondreplyid == 0 ? 0 : respondreplyid,
                            response: checkingstuff,
                          );
                        }
                        replyid = 0;
                        response = "";
                        respondreplyid = 0;
                        replyactivated = false;
                      } else {
                        await upLoadingChat(settingsProvider: settingsProvider);
                      }
                      chatController.text = "";
                      checkingpromptdone = true;
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activesend
                          ? Colors.green
                          : Theme.of(context).splashColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.airplanemode_active_rounded),
                  ),
                ),
              )
      ],
    );
  }

  Row reciever({
    required bool replyin,
    required String replycontent,
    required String msgcontent,
    required int chatid,
    required void Function()? onTap,
    required SettingsProvider settingsProvider,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  replyin
                                      ? Container(
                                          padding: const EdgeInsets.all(9),
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).splashColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(30),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(Icons.person),
                                                  ),
                                                  Text("Replied to You"),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 9),
                                                child: Text(replycontent),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                  parseMarkdown(msgcontent),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  selectedchatbox.contains(chatid)
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                        )
                                      : const SizedBox(),
                                  activesearch
                                      ? Container(
                                          padding: const EdgeInsets.all(1),
                                          width: 80,
                                          margin:
                                              const EdgeInsets.only(left: 20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.pink,
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      respondreplyid = chatid;
                      replyactivated = true;
                      replyingcontent = msgcontent;
                      replyid = 0;
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.reply,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      String response = msgcontent.replaceAll("*", "");
                      response = response.replaceAll("#", "");
                      await FlutterClipboard.copy(response);
                      errormsg(context: context, error: "Item Copied");
                    },
                    icon: const Icon(
                      Icons.copy,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (!isSpeaking) {
                        speakstring = msgcontent.replaceAll("#", "");
                        speakstring = speakstring.replaceAll("*", "");
                        speak(
                          textToConvert: speakstring,
                          context: context,
                          rate: settingsProvider.settings.fast
                              ? kIsWeb
                                  ? 1.4
                                  : 0.4
                              : kIsWeb
                                  ? 1
                                  : 0.3,
                        );
                      } else {
                        stopspeaking();
                      }
                    },
                    icon: isSpeaking
                        ? const Icon(
                            Icons.stop_rounded,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.envelope_open_fill))
      ],
    );
  }

  Column sender({
    required bool replyin,
    required bool toai,
    required String replycontent,
    required String msgcontent,
    required String datetime,
    required int chatid,
    required bool noresponse,
    required void Function()? onTap,
    required void Function()? delTap,
    required SettingsProvider settingsProvider,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(datetime),
        ),
        Row(
          children: [
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            replyin
                                ? Container(
                                    padding: const EdgeInsets.all(9),
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        toai
                                            ? Row(
                                                children: [
                                                  Image.asset(
                                                    "lib/assets/new degreen ic.png",
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  const Text(
                                                      "Replied to Degreen"),
                                                ],
                                              )
                                            : const Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(Icons.person),
                                                  ),
                                                  Text("Replied to Yourself"),
                                                ],
                                              ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 9),
                                          child: Text(replycontent),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            Text(msgcontent),
                            const SizedBox(
                              height: 7,
                            ),
                            selectedchatbox.contains(chatid)
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                  )
                                : const SizedBox(),
                            activesearch
                                ? Container(
                                    padding: const EdgeInsets.all(1),
                                    width: 80,
                                    margin: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.pink,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          respondreplyid = 0;
                          replyactivated = true;
                          replyingcontent = msgcontent;
                          replyid = chatid;
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.reply,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String response = msgcontent.replaceAll("*", "");
                          response = response.replaceAll("#", "");
                          await FlutterClipboard.copy(response);
                          errormsg(context: context, error: "Item Copied");
                        },
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (!isSpeaking) {
                            speakstring = msgcontent.replaceAll("#", "");
                            speakstring = speakstring.replaceAll("*", "");
                            speak(
                              textToConvert: speakstring,
                              context: context,
                              rate: settingsProvider.settings.fast
                                  ? kIsWeb
                                      ? 1.4
                                      : 0.4
                                  : kIsWeb
                                      ? 1
                                      : 0.3,
                            );
                          } else {
                            stopspeaking();
                          }
                        },
                        icon: isSpeaking
                            ? const Icon(
                                Icons.stop_rounded,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.volume_up_rounded,
                                size: 18,
                              ),
                      ),
                      IconButton(
                        onPressed: delTap,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget typing() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Lottie.asset(
        'lib/assets/typing.json',
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget packagerdesign() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).hoverColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.envelope_fill),
                      Text("    Packaged in"),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Extract Package ?'),
                            content: const Text(
                                "Extract this content from title of package"),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text('Proceed'),
                                onPressed: () {
                                  //extract function
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(CupertinoIcons.tray_arrow_up_fill),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Text(
                  "Title of package here",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Text(
                "Date time for chat",
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
      } else {
        // for bolding
        // line = line.
        if (line.contains("**")) {
          textspans.add(boldText(line)[0]);
          inhere = boldText(line)[1];
        } else if (line.contains("*")) {
          textspans.add(italicText(line)[0]);
          inhere = italicText(line)[1];
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
        }
      }
    }
    Widget markdownedit = SelectableText.rich(
      TextSpan(children: textspans),
    );
    setState(() {});
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

  void uploadnoresponse({
    required String msg,
    required int replyid,
    required int resreplyid,
  }) async {
    await addChat(
      msg: msg,
      replyid: replyid == 0 ? "none" : replyid.toString(),
      resreplyid: resreplyid == 0 ? "none" : resreplyid.toString(),
      respond: '',
    );
    errormsg(
        context: context,
        error: "We are offline now, Try connecting to the internet");
  }

  Future<void> upLoadingChat({
    required SettingsProvider settingsProvider,
  }) async {
    setState(() {
      response = "loading";
    });
    String mainprompt = "";

    try {
      var translated =
          await chatController.text.translate(from: 'auto', to: 'en');
      mainprompt = translated.text;
      response = await trainer(
        settingsProvider: settingsProvider,
        what:
            "is '$mainprompt' referencing a previous conversation or attempting to correct / improve a previous response?",
        how: "i need only a yes or no answer",
      );
      if (response.toLowerCase().contains("yes")) {
        response = await Topics().usingGermini(
          what: mainprompt,
        );
        response +=
            "\n **If you are replying to any chat click on its reply button to be specific**";
      } else {
        response = await Topics().usingGermini(
          what: mainprompt,
        );
      }

      if (!response.contains("Error")) {
        var translated =
            await response.translate(to: settingsProvider.settings.language);
        response = translated.text;
        uploadwithresponse(
          msg: chatController.text,
          replyid: replyid,
          response: response,
          resreplyid: respondreplyid,
        );
      } else {
        uploadnoresponse(
          msg: chatController.text,
          replyid: replyid,
          resreplyid: respondreplyid,
        );
      }
    } on Exception {
      uploadnoresponse(
        msg: chatController.text,
        replyid: replyid,
        resreplyid: respondreplyid,
      );
    }
    response = "";
    setState(() {});
  }

  Future<String> trainer({
    required SettingsProvider settingsProvider,
    required String what,
    required String how,
  }) async {
    setState(() {
      response = "loading";
    });
    String mainprompt = "";

    try {
      var translated = await what.translate(from: 'auto', to: 'en');
      mainprompt = how + translated.text;
      response = await Topics().usingGermini(
        what: mainprompt,
      );
      if (!response.contains("Error")) {
        var translated =
            await response.translate(to: settingsProvider.settings.language);
        response = translated.text;
        return response;
      } else {
        return "error----error-error--";
      }
    } on Exception {
      return "error----error-error--";
    }
  }

  void errormsg({required BuildContext context, required String error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      error,
      textAlign: TextAlign.center,
    )));
  }

  void uploadwithresponse({
    required String msg,
    required int replyid,
    required int resreplyid,
    required String response,
  }) async {
    await addChat(
      msg: msg,
      replyid: replyid == 0 ? "none" : replyid.toString(),
      resreplyid: resreplyid == 0 ? "none" : resreplyid.toString(),
      respond: response,
    );
  }

  void deletingchat({required chatid}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat ?'),
          content:
              const Text("This will delete the sent and responds of this chat"),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () async {
                await _deleteChat(chatid);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
