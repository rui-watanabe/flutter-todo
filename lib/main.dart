import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// アプリの基盤のUIとなる部分
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// アプリのコンポーネントを呼び出す
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// アプリのコンポーネント
class _MyHomePageState extends State<MyHomePage> {
  // テキストフィールドのメソッドを提供
  TextEditingController textController = TextEditingController();
  // ローカルのTODOリスト
  List<String> todoLists = ["hoge", "fuga", "hage", "fuge"];
  // ローカルのテキストフィールドの文字列
  String todo = "";

  // アプリ初期化じに呼び出される
  void initState() {
    super.initState();
    initdata();
  }

  // key value形式の端末内保存データを初期化
  initdata() async {
    SharedPreferences prfs = await SharedPreferences.getInstance();
    var result = prfs.getStringList("todo");
    if (result != null) {
      setState(() {
        todoLists = result;
      });
    }
  }

  // key value形式の端末内保存データを更新
  updateData(List<String> updateTodoLists) async {
    SharedPreferences prfs = await SharedPreferences.getInstance();
    var result = prfs.setStringList("todo", updateTodoLists);
    initdata();
  }

  // 追加のダイアログ表示
  displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          // state更新して画面を再描画するために必要
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: TextField(
                  controller: textController,
                  onChanged: (value) {
                    // テキストフィールドが呼び出されるたびにtodoの変数を更新
                    setState(() {
                      todo = value;
                    });
                  },
                ),
                actions: [
                  // 追加ボタン
                  ElevatedButton(
                    onPressed: todo.isEmpty
                        // nullだったら非活性
                        ? null
                        : () {
                            // 何か文字が入っていたら更新
                            setState(() => {
                                  // ローカルのステートと端末内保存データを更新してテキストフィールドを初期化しダイアログを閉じる処理
                                  todoLists.add(todo),
                                  textController.clear(),
                                  updateData(todoLists),
                                  Navigator.pop(context)
                                });
                          },
                    child: Text("add"),
                  ),
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          // 端末の高さや横幅を自動計算してサイズを決める
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.height,
          color: Colors.grey,
          // リスト表示を行う
          child: ListView.builder(
            // リスト表示の数
            itemCount: todoLists.length,
            // リスト表示の内容
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  // sildableライブラリーを使ってスライドした際に削除アイコンが表示されるようにする
                  child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: [
                        IconSlideAction(
                          caption: "delete",
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () {
                            // 削除した際はローカルのtodoListsと端末内のデータを更新する
                            setState(() => {
                                  todoLists.remove(todoLists[index]),
                                  textController.clear(),
                                  updateData(todoLists),
                                });
                          },
                        )
                      ],
                      // 一つ一つのリストの中身の更新
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          color: Colors.blueAccent,
                          child: Text(
                            todoLists[index],
                            style: TextStyle(fontSize: 50),
                          ))));
            },
          ),
        ),
      ),
      // 右下のTODOを追加するためのアイコン表示とアイコン押下時のダイアログ表示
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          displayDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
