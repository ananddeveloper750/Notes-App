import 'package:flutter/material.dart';
import 'package:notes_app/Data/Local/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  List<Map<String, dynamic>> filteredNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    getAllNotes();
  }

  void getAllNotes() async {
    dbRef = DBHelper.getInstance;
    allNotes = await dbRef!.getAllNotes();
    filteredNotes = List.from(allNotes);
    setState(() {});
  }

  void filterNotes(String query) {
    if (query.isEmpty) {
      filteredNotes = List.from(allNotes);
    } else {
      filteredNotes = allNotes.where((note) {
        final title = note[DBHelper.TABLE_NOTE_TITLE].toString().toLowerCase();
        final desc = note[DBHelper.TABLE_NOTE_DESC].toString().toLowerCase();
        return title.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  RichText highlightText(String source, String query) {
    if (query.isEmpty) {
      return RichText(
        text: TextSpan(
          text: source,
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    final matches = <TextSpan>[];
    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerSource.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        matches.add(TextSpan(
          text: source.substring(start, index),
          style: TextStyle(color: Colors.black),
        ));
      }

      matches.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));

      start = index + query.length;
      index = lowerSource.indexOf(lowerQuery, start);
    }

    if (start < source.length) {
      matches.add(TextSpan(
        text: source.substring(start),
        style: TextStyle(color: Colors.black),
      ));
    }

    return RichText(text: TextSpan(children: matches));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: filterNotes,
              decoration: InputDecoration(
                hintText: "Search",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(child: Text("Notes not Available"))
                : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  title: highlightText(
                    filteredNotes[index][DBHelper.TABLE_NOTE_TITLE],
                    searchController.text,
                  ),
                  subtitle: highlightText(
                    filteredNotes[index][DBHelper.TABLE_NOTE_DESC],
                    searchController.text,
                  ),
                  leading: Text(
                    "${index+1}",
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                title.text = filteredNotes[index][DBHelper.TABLE_NOTE_TITLE];
                                desc.text = filteredNotes[index][DBHelper.TABLE_NOTE_DESC];
                                return getBottomSheet(
                                  isUpdate: true,
                                  sno: filteredNotes[index][DBHelper.TABLE_NOTE_SR_NO],
                                );
                              },
                            );
                          },
                          child: Icon(Icons.edit,size: 30,),
                        ),
                        SizedBox(width: 25),
                        InkWell(
                          onTap: () async {
                            bool check = await dbRef!.deleteNote(
                              index: filteredNotes[index][DBHelper.TABLE_NOTE_SR_NO],
                            );
                            if (!context.mounted) return;
                            if (check) {
                              getAllNotes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Note deleted successfully")),
                              );
                            }
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          title.clear();
          desc.clear();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return getBottomSheet();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheet({bool isUpdate = false, int sno = 0}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              isUpdate ? "Update Notes" : "Add Notes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 70),
            TextField(
              controller: title,
              decoration: InputDecoration(
                label: Text("Title"),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: desc,
              maxLines: null,
              decoration: InputDecoration(
                label: Text("Description"),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () async {
                if (title.text.isNotEmpty && desc.text.isNotEmpty) {
                  bool? check = isUpdate
                      ? await dbRef?.updateNote(
                      title: title.text, desc: desc.text, sno: sno)
                      : await dbRef?.addNote(
                      mTitle: title.text, mDesc: desc.text);
                  if (check!) getAllNotes();
                  title.clear();
                  desc.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isUpdate ? "Note updated" : "Note added")),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    isUpdate ? "Update Notes" : "Add Notes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
