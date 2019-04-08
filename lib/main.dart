import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

String getContent(n) {
  if (n == -4) {
    return "💀";
  }
  if (n == -2 || n == -3) {
    return "💣";
  }
  if (n > 0 && n < 9) {
    return n.toString();
  }
  return "";
}

List<int> getNeighbors(int i, int M, int N) {
  var x = i ~/ N, y = i % N;
  var list = List<int>();
  for (var i = -1; i < 2; i++) {
    for (var j = -1; j < 2; j++) {
      var xi = x + i, yj = y + j;
      if (xi < 0 || xi >= M || yj < 0 || yj >= N || (i == 0 && j == 0)) {
        continue;
      }
      list.add(xi * N + yj);
    }
  }
  return list;
}

void spread(List<int> state, int i, int M, int N) {
  getNeighbors(i, M, N).forEach((x) {
    if (state[x] == 0) {
      reveal(state, x, M, N);
    }
  });
}

void reveal(List<int> state, int i, int M, int N) {
  if (state[i] != 0) {
    return;
  }
  var count = getNeighbors(i, M, N).map((x) {
    var neighbor = state[x];
    return (neighbor < 0 && neighbor != -3) ? 1 : 0;
  }).reduce((a, b) => a + b);
  if (count > 0) {
    state[i] = count;
  } else {
    state[i] = 9;
    spread(state, i, M, N);
  }
}

Future<void> restart(BuildContext context, bool success, f) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('You ${success ? "Win" : "lose"}!'),
        actions: <Widget>[
          FlatButton(
            child: Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop();
              f();
            },
          ),
        ],
      );
    },
  );
}

Future<void> settings(BuildContext context, f) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Settings'),
        actions: <Widget>[
          FlatButton(
            child: Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop();
              f();
            },
          ),
        ],
      );
    },
  );
}

class _Home extends State<Home> {
  List<int> state = [];
  int N = 8, M = 30;
  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    setState(() {
      state = List.generate(M*N, (i) => i < M*N / 5 ? -1 : 0)..shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    var buttons = List.from(state.asMap().keys).map((i) => ButtonTheme(
            child: GestureDetector(
          onLongPress: () {
            setState(() {
              if (state[i] > 0) {
                return;
              }
              if (state[i] == -1) {
                state[i] = -2;
              } else if (state[i] == -2 || state[i] == -3) {
                state[i] = 0;
              } else {
                state[i] = -3;
              }
              Feedback.forLongPress(context);
            });
          },
          child: RaisedButton(
            child: Text(getContent(state[i]),
                textAlign: TextAlign.center, style: TextStyle(fontSize: 25)),
            onPressed: state[i] <= 0
                ? () {
                    setState(() {
                      if (state[i] == -1) {
                        state[i] = -4;
                        restart(context, false, reset);
                        return;
                      }
                      if (state[i] > -1) {
                        reveal(state, i, M, N);
                      }
                      if (state.indexOf(0) == -1 && state.indexOf(-4) == -1) {
                        restart(context, true, reset);
                      }
                    });
                  }
                : null,
          ),
        )));
    return MaterialApp(
        home: Scaffold(
            appBar: new AppBar(
                title: new Text("Flutter Minesweeper"), centerTitle: true),
            body: Center(
              child: GridView.count(
                crossAxisCount: N,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
                padding: const EdgeInsets.only(
                    left: 7, right: 7, top: 7, bottom: 30),
                children: buttons.toList(),
              ),
            )));
  }
}
