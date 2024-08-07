import 'package:degreen/pages/chatzone.dart';
import 'package:degreen/pages/saved_items_page.dart';
import 'package:degreen/pages/search.dart';
import 'package:degreen/pages/settings.dart';
import 'package:degreen/pages/topicpreviewer.dart';
import 'package:degreen/topics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  bool _isColumnLayout = true;
  bool isAscending = true;
  List<List<dynamic>> data = Topics().globalChallenges();
  String transtopic = "";
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sortData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _sortData() {
    if (isAscending) {
      Topics().bubbleSortAscending(data);
    } else {
      Topics().bubbleSortDescending(data);
    }
  }

  void _toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      _sortData();
    });
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isColumnLayout) {
        setState(() {
          _isColumnLayout = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isColumnLayout) {
        setState(() {
          _isColumnLayout = true;
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
    } else if (screenWidth >= 600) {
      deviceType = 'tablet';
    } else {
      deviceType = 'mobile';
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatZone(
                reply: '',
              ),
            ),
          ),
          icon: const Icon(Icons.chat_rounded),
        ),
        title: const Text('De Green'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SavedItemsPage(),
              ));
            },
            icon: const Icon(Icons.folder),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Settingspage(),
                ));
              },
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            floating: true,
            leading: !_isColumnLayout
                ? Image.asset(
                    "lib/assets/new degreen ic.png",
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
            pinned: true,
            actions: !_isColumnLayout
                ? [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Searchterm(),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          margin: const EdgeInsets.only(right: 12),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context).hoverColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("Search"),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton.filledTonal(
                        onPressed: _toggleSortOrder,
                        icon: const Icon(Icons.sort_by_alpha),
                      ),
                    )
                  ]
                : const [SizedBox()],
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: deviceType == "mobile"
                    ? standhero(context: context, type: "m")
                    : deviceType == "huge"
                        ? standhero(context: context, type: "h")
                        : standhero(context: context, type: "t"),
              ),
            ),
          ),
          deviceType != "mobile"
              ? SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(data.length, (index) {
                        return topics(
                          icon: data[index][2],
                          topic: data[index][0],
                          subcontent: data[index][1],
                          descriptions: data[index][3],
                          type: 'h',
                          index: index,
                        );
                      }),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return topics(
                        icon: data[index][2],
                        topic: data[index][0],
                        subcontent: data[index][1],
                        descriptions: data[index][3],
                        type: 'm',
                        index: index,
                      );
                    },
                    childCount: data.length,
                  ),
                ),
        ],
      ),
    );
  }

  Column standhero({required BuildContext context, required String type}) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          width: double.infinity,
          child: Center(
            child: Image.asset(
              "lib/assets/new degreen ic.png",
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              type == "m"
                  ? Expanded(
                      child: searchbar(context),
                    )
                  : searchbar(context),
              const SizedBox(
                width: 12,
              ),
              IconButton.filledTonal(
                onPressed: _toggleSortOrder,
                icon: const Icon(Icons.sort_by_alpha),
              )
            ],
          ),
        ),
      ],
    );
  }

  MouseRegion searchbar(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Searchterm(),
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).hoverColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Search"),
              ),
              Icon(
                Icons.search,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topics({
    required IconData icon,
    required String topic,
    required String subcontent,
    required List<dynamic> descriptions,
    required String type,
    required int index,
  }) {
    if (index == data.length - 1) {
      return const SizedBox(
        height: 8,
        width: double.infinity,
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Topicpreviewer(
                topic: topic,
                descriptions: descriptions,
                icondata: icon,
              ),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            width: type == "h" ? 300 : double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              border: Border.all(
                width: 5,
                color: Theme.of(context).hoverColor,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subcontent,
                        style: const TextStyle(
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
