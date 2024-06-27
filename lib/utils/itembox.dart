import 'package:flutter/material.dart';

class Itembox extends StatefulWidget {
  final String title;
  final String content;
  final String datetime;
  final void Function() edit;
  final void Function() delete;
  const Itembox({
    super.key,
    required this.title,
    required this.content,
    required this.datetime,
    required this.edit,
    required this.delete,
  });

  @override
  State<Itembox> createState() => _ItemboxState();
}

class _ItemboxState extends State<Itembox> {
  @override
  Widget build(BuildContext context) {
    List<String> titlesplitter = widget.title.split("-::::-");
    String title = titlesplitter[0];
    String subtitle = titlesplitter[1];
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).splashColor,
        border: Border.all(
          width: 5,
          color: Theme.of(context).hoverColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
          const Divider(
            thickness: 3,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).splashColor,
            ),
            child: Text(widget.content),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.datetime,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: widget.edit,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).splashColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                      onTap: widget.delete,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_forever),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}