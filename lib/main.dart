import 'package:flutter/material.dart';
import 'package:sqlite_db_example/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _items = [];
  bool isLoading = true;
  void refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshItems();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptController = TextEditingController();

  void showItems(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      titleController.text = existingItem['title'];
      descriptController.text = existingItem['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptController,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () async {
                          if (id == null) {
                            await addItem();
                          }
                          if (id != null) {
                            await updateItem(id);
                          }
                          titleController.text = '';
                          descriptController.text = '';
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        child: Text(id == null ? 'Create New' : 'Update'))
                  ]),
            ));
  }

//insert a new item to database
  Future<void> addItem() async {
    await SQLHelper.createItem(titleController.text, descriptController.text);
    refreshItems();
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id, titleController.text, descriptController.text);
    refreshItems();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.orange[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(_items[index]['title']),
                    subtitle: Text(_items[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showItems(_items[index]['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteItem(_items[index]['id']),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showItems(null),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
