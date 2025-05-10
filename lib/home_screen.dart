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
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllNotes();
  }

  void getAllNotes() async {
    dbRef = DBHelper.getInstance;
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
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
      body:
          allNotes.isEmpty
              ? Center(child: Text("Notes not Available"))
              : ListView.builder(
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(
                      "${allNotes[index][DBHelper.TABLE_NOTE_TITLE]}",
                    ),
                    subtitle: Text(
                      "${allNotes[index][DBHelper.TABLE_NOTE_DESC]}",
                    ),
                    leading: Text(
                      "${allNotes[index][DBHelper.TABLE_NOTE_SR_NO]}",
                    ),
                    trailing: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          //UpdateNotes
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  title.text =
                                      allNotes[index][DBHelper
                                          .TABLE_NOTE_TITLE];
                                  desc.text =
                                      allNotes[index][DBHelper.TABLE_NOTE_DESC];
                                  return getBottomSheet(
                                    isUpdate: true,
                                    sno:
                                        allNotes[index][DBHelper
                                            .TABLE_NOTE_SR_NO],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.edit),
                          ),
                          SizedBox(width: 5),

                          /// Delete Notes
                          InkWell(
                            onTap: () async {
                              bool check = await dbRef!.deleteNote(
                                index:
                                    allNotes[index][DBHelper.TABLE_NOTE_SR_NO],
                              );
                              if (!context.mounted) return;
                              if (check) {
                                getAllNotes();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Notes delete Successfully"),
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        bottom:
            MediaQuery.of(
              context,
            ).viewInsets.bottom, // Keyboard height ke according padding
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isUpdate ? "Update Notes" : "Add Notes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 70),
            TextField(
              controller: title,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Title"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: desc,
              maxLines: null,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Description"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () async {
                if (title.text.isNotEmpty && desc.text.isNotEmpty) {
                  bool? check =
                      isUpdate
                          ? await dbRef?.updateNote(
                            title: title.text.toString(),
                            desc: desc.text.toString(),
                            sno: sno,
                          )
                          : await dbRef?.addNote(
                            mTitle: title.text.toString(),
                            mDesc: desc.text.toString(),
                          );
                  if (check!) {
                    getAllNotes();
                  }
                  title.clear();
                  desc.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          isUpdate
                              ? Text("Notes Update Successfully")
                              : Text("Notes Added Successfully"),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please feel the all required field"),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      isUpdate ? "Update Notes" : "Add notes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
