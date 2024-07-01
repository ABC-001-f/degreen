import 'package:degreen/utils/content.dart';
import 'package:degreen/utils/itembox.dart';
import 'package:degreen/utils/storage_helper.dart';
import 'package:flutter/material.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  List<Content> _contentList = [];
  String _sortCriterion = 'date';
  bool _ascending = true, searchactive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContent();
    _searchController.addListener(_loadContent);
  }

  @override
  void dispose() {
    _searchController.addListener(_loadContent);
    super.dispose();
  }

  void _loadContent() {
    setState(() {
      _contentList = StorageHelper.getAllContent();
      _sortContent();
    });
  }

  void _sortContent() {
    setState(() {
      if (_sortCriterion == 'date') {
        _contentList.sort((a, b) => _ascending
            ? a.datetime.compareTo(b.datetime)
            : b.datetime.compareTo(a.datetime));
      } else if (_sortCriterion == 'title') {
        _contentList.sort((a, b) => _ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
      } else if (_sortCriterion == 'search') {
        String query = _searchController.text.toLowerCase();
        _contentList = _contentList.where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.content.toLowerCase().contains(query);
        }).toList();
        _contentList.sort((a, b) => _ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
      }
    });
  }

  void _deleteContent(int index) {
    final content = _contentList[index];
    StorageHelper.deleteContent(index);
    StorageHelper.deleteContentFromFile(content.datetime);
    _loadContent();
  }

  void _updateContent(int index, String newTitle, String newContent) {
    final updatedContent = Content(
      title: newTitle,
      datetime: _contentList[index].datetime,
      content: newContent,
    );
    StorageHelper.updateContent(index, updatedContent);
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    String deviceType = "";
    if (deviceWidth >= 600) {
      deviceType = 'huge';
    } else {
      deviceType = 'mobile';
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Items'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _sortCriterion = value;
                  value == "search" ? searchactive = true : searchactive = false;
                  _sortContent();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date',
                  child: Text('Sort by Date'),
                ),
                const PopupMenuItem(
                  value: 'title',
                  child: Text('Sort by Title'),
                ),
                const PopupMenuItem(
                  value: 'search',
                  child: Text('Sort by Search'),
                ),
              ],
            ),
            IconButton(
              icon:
                  Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () {
                setState(() {
                  _ascending = !_ascending;
                  _sortContent();
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            searchactive
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            _contentList.isEmpty
                ? const Center(child: Text('No items found'))
                : Center(
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: List.generate(
                          _contentList.length,
                          (index) {
                            final content = _contentList[index];
                            return SizedBox(
                              width: deviceType == "mobile" ? deviceWidth : 300,
                              child: Itembox(
                                title: content.title,
                                content: content.content,
                                datetime: content.datetime.toIso8601String(),
                                edit: () {
                                  _showEditDialog(index);
                                },
                                delete: () {
                                  _deleteContent(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ));
  }

  void _showEditDialog(int index) {
    List<String> titlesplitter = _contentList[index].title.split("-::::-");
    String title = titlesplitter[0];
    String subtitle = titlesplitter[1];
    final titleController = TextEditingController(text: title);
    final subtitleController = TextEditingController(text: subtitle);
    final contentController =
        TextEditingController(text: _contentList[index].content);

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
              child: const Text('Save'),
              onPressed: () {
                final title =
                    "${titleController.text}-::::-${subtitleController.text}";
                _updateContent(
                    index, title, contentController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
