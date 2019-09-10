import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Goals",
      debugShowCheckedModeBanner: false,
      home: new HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _editingController = new TextEditingController();
  SharedPreferences prefs;
  List<String> _goalsList = [];
  List<String> _completedList = [];

  @override
  initState() {
    super.initState();
    init();
  }

  void init() async {
    print("INFO: Init called");
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalsList = prefs.getStringList("goals") ?? [];
      _completedList = prefs.getStringList("cGoals") ?? [];
    });
  }

  Widget _goal(String text) {
    final bool _status = _completedList.contains(text);
    return Card(
      color: _status ? Colors.greenAccent : Colors.redAccent,
      //margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
      child: InkWell(
        splashColor: Theme.of(context).splashColor,
        splashFactory: Theme.of(context).splashFactory,
        child: new Container(
          padding: const EdgeInsets.all(16.0),
          child: new Row(
            children: <Widget>[
              _status
                  ? new Text(
                      text,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 20.0,
                      ),
                    )
                  : new Text(
                      text,
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _status ? _completedList.remove(text) : _completedList.add(text);
            _status ? _goalsList.add(text) : _goalsList.remove(text);
            prefs.setStringList("cGoals", _completedList);
            prefs.setStringList("goals", _goalsList);
          });
        },
      ),
    );
  }

  Widget _addGoalDialog() {
    return new SimpleDialog(
      title: Text("New Goal"),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(8.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "Enter your goal",
                border: OutlineInputBorder(),
                hintText: "Enter your ambitious goal"),
            controller: _editingController,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 80.0),
          child: MaterialButton(
            color: Theme.of(context).primaryColor,
            shape: StadiumBorder(),
            textColor: Colors.white,
            child: Text("Add"),
            onPressed: () {
              setState(() {
                _goalsList.add(_editingController.text);
                prefs.setStringList("goals", _goalsList);
              });
              _editingController.clear();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddGoal() {
    return new Container(
      margin: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _addGoalDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goals"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8.0, right: 26.0, left: 26.0),
        child: new Column(
          children: <Widget>[
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_goalsList[index]),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: AlignmentDirectional.centerStart,
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _goalsList.removeAt(index);
                      prefs.setStringList("goals", _goalsList);
                    });
                  },
                  child: _goal(_goalsList[index]),
                );
              },
              itemCount: _goalsList.length,
            ),
            new Divider(
              height: 16.0,
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_completedList[index]),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: AlignmentDirectional.centerStart,
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _completedList.removeAt(index);
                      prefs.setStringList("cgoals", _completedList);
                    });
                  },
                  child: _goal(_completedList[index]),
                );
              },
              itemCount: _completedList.length,
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddGoal(),
    );
  }
}
