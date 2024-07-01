import 'package:degreen/pages/topicpreviewer.dart';
import 'package:degreen/topics.dart';
import 'package:flutter/material.dart';

class Searchterm extends StatefulWidget {
  const Searchterm({super.key});

  @override
  State<Searchterm> createState() => _SearchtermState();
}

class _SearchtermState extends State<Searchterm> {
  List<List<dynamic>> data = Topics().globalChallenges();
  List<List<dynamic>> filteredData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredData = data;
    Topics().bubbleSortAscending(data);
    searchController.addListener(filterData);
  }

  @override
  void dispose() {
    searchController.removeListener(filterData);
    searchController.dispose();
    super.dispose();
  }

  void filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = data
          .where((item) =>
              item[0].toLowerCase().contains(query) ||
              item[1].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String deviceType = "";
    if (screenWidth >= 1200) {
      deviceType = 'huge';
    } else if (screenWidth >= 650) {
      deviceType = 'tablet';
    } else {
      deviceType = 'mobile';
    }
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.chevron_left),
        ),
        title: const Text("Search"),
        actions: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              "lib/assets/new degreen ic.png",
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: deviceType == "mobile"
                ? const EdgeInsets.all(8.0)
                : const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: deviceType != "mobile"
                ? SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        filteredData.length,
                        (index) => topics(
                          icon: filteredData[index][2],
                          topic: filteredData[index][0],
                          subcontent: filteredData[index][1],
                          descriptions: filteredData[index][3],
                          type: 'h',
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return topics(
                        icon: filteredData[index][2],
                        topic: filteredData[index][0],
                        subcontent: filteredData[index][1],
                        descriptions: filteredData[index][3],
                        type: 'm',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  GestureDetector topics({
    required IconData icon,
    required String topic,
    required String subcontent,
    required List<dynamic> descriptions,
    required String type,
  }) {
    return GestureDetector(
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
    );
  }
}
