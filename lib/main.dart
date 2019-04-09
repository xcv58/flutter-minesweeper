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
  var res = List<int>();
  for (var i = -1; i < 2; i++) {
    for (var j = -1; j < 2; j++) {
      var xi = x + i, yj = y + j;
      if (xi < 0 || xi >= M || yj < 0 || yj >= N || (i == 0 && j == 0)) {
        continue;
      }
      res.add(xi * N + yj);
    }
  }
  return res;
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

restart(BuildContext context, bool win, f) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('You ${win ? "Win" : "Lose"}!'),
        actions: [
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

settings(BuildContext context, int M, int N, mf, nf, cb) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      var content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Row"),
            keyboardType: TextInputType.number,
            onChanged: mf,
          ),
          TextField(
            decoration: InputDecoration(labelText: "Column"),
            keyboardType: TextInputType.number,
            onChanged: nf,
          ),
        ],
      );
      var actions = [
        FlatButton(
          child: Text('Submit'),
          onPressed: () {
            Navigator.of(context).pop();
            cb();
          },
        ),
      ];
      return AlertDialog(
          title: Text('Setting'), content: content, actions: actions);
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
      state = List.generate(M * N, (i) => i < M * N / 5 ? -1 : 0)..shuffle();
    });
  }

  void mark(int i) {
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
  }

  void onDoubleTap(int i) {
    if (revealed(i)) {
      revealNeighbor(i);
    } else if (isMarked(i) || isBlank(i)) {
      mark(i);
    }
  }

  bool isMarked(int i) {
    return state[i] == -2 || state[i] == -3;
  }

  bool isBlank(i) {
    return state[i] == 0 || state[i] == -1;
  }

  void revealNeighbor(int i) {
    setState(() {
      var neighbors = getNeighbors(i, M, N);
      var markedNeighborCount =
          neighbors.map((x) => isMarked(x) ? 1 : 0).reduce((a, b) => a + b);
      debugPrint('markedNeighborCount: $markedNeighborCount');
      if (markedNeighborCount >= state[i]) {
        neighbors.where(isBlank).forEach((x) {
          onPressed(x);
        });
      }
    });
  }

  void onPressed(i) {
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

  bool revealed(i) {
    return state[i] > 0 && state[i] < 9;
  }

  Widget _button(i) {
    var child = FlatButton(
        color: Colors.blue,
        disabledColor: Colors.grey,
        child: Text(getContent(state[i]),
            textAlign: TextAlign.center, style: TextStyle(fontSize: 25)),
        onPressed: state[i] <= 0
            ? () {
                onPressed(i);
              }
            : null);
    return GestureDetector(
      onDoubleTap: () {
        onDoubleTap(i);
      },
      onLongPress: () {
        onDoubleTap(i);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    var buttons = List.from(state.asMap().keys).map(_button);
    var actions = [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          settings(context, M, N, (String m) {
            setState(() {
              M = int.parse(m);
            });
          }, (String n) {
            setState(() {
              N = int.parse(n);
            });
          }, reset);
        },
      )
    ];
    var appBar = AppBar(
        title: new Text("Flutter Minesweeper"),
        centerTitle: true,
        actions: actions);
    var body = Center(
      child: GridView.count(
        crossAxisCount: N,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        padding: EdgeInsets.fromLTRB(7, 7, 7, 30),
        children: buttons.toList(),
      ),
    );
    return MaterialApp(home: Scaffold(appBar: appBar, body: body));
  }
}
