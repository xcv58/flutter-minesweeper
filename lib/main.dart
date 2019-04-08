import 'package:flutter/material.dart';

void main() => runApp(Home());

var N = 8, M = 30, LEN = M * N;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            title: new Text("Flutter Minesweeper"), centerTitle: true),
        body: new Content());
  }
}

class Content extends StatefulWidget {
  @override
  _Content createState() => _Content();
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

List<int> getNeighbors(int i) {
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

void spread(state, i) {
  getNeighbors(i).forEach((x) {
    if (state[x] == 0) {
      reveal(state, x);
    }
  });
}

void reveal(List state, i) {
  if (state[i] != 0) {
    return;
  }
  var count = getNeighbors(i).map((x) {
    var neighbor = state[x];
    return (neighbor < 0 && neighbor != -3) ? 1 : 0;
  }).reduce((a, b) => a + b);
  if (count > 0) {
    state[i] = count;
  } else {
    state[i] = 9;
    spread(state, i);
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

class _Content extends State<Content> {
  List state = [];
  @override
  void initState() {
    setState(() {
      state = List.generate(LEN, (i) => i < LEN / 5 ? -1 : 0)..shuffle();
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
                        restart(context, false, this.initState);
                        return;
                      }
                      if (state[i] > -1) {
                        reveal(state, i);
                      }
                      if (state.indexOf(0) == -1 && state.indexOf(-4) == -1) {
                        restart(context, true, this.initState);
                      }
                    });
                  }
                : null,
          ),
        )));
    return new Center(
      child: GridView.count(
        crossAxisCount: N,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        padding: const EdgeInsets.only(left: 7, right: 7, top: 7, bottom: 30),
        children: buttons.toList(),
      ),
    );
  }
}
