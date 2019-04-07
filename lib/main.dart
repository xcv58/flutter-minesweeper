import 'package:flutter/material.dart';

void main() => runApp(MyApp());

var N = 8, M = 30, LEN = M * N;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0,
        title: new Text("Flutter Minesweeper"),
        centerTitle: true
      ),
      body:new HomeContent()
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

String getContent(n) {
  // return n.toString();
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

void spread(state, t) {
  var x = (t / N).toInt(), y = t % N;
  for (var i = -1; i < 2; i++) {
    for (var j = -1; j < 2; j++) {
      var xi = x + i, yj = y + j;
      debugPrint('$xi, $yj');
      if (xi < 0 || xi >= M) {
        continue;
      }
      if (yj < 0 || yj >= N) {
        continue;
      }
      var neighbor = state[xi*N+yj];
      if (neighbor == 0) {
        reveal(state, xi*N+yj);
      }
    }
  }
}

void reveal(List state, i) {
  if (state[i] != 0) {
    return;
  }
  var x = (i / N).toInt(), y = i % N;
  debugPrint('onPressed index: ${i}; ${x}, ${y}');
  var count = 0;
  for (var i = -1; i < 2; i++) {
    for (var j = -1; j < 2; j++) {
      var xi = x + i, yj = y + j;
      debugPrint('$xi, $yj');
      if (xi < 0 || xi >= M) {
        continue;
      }
      if (yj < 0 || yj >= N) {
        continue;
      }
      var neighbor = state[xi*N+yj];
      debugPrint('$xi, $yj: state[${xi*N+yj}] = $neighbor');
      count += (neighbor < 0 && neighbor != -3) ? 1 : 0;
    }
  }
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

class _HomeContentState extends State<HomeContent>{
  List state = [];
  @override
  void initState() {
    setState(() {
      state = List.generate(LEN, (i) => i < LEN / 15 ? -1 : 0)..shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    var buttons = List.from(state.asMap().keys).map((i) => ButtonTheme(
      child: GestureDetector(
        onLongPress: () {
          // -1 is unchecked
          // -2 is marked correct
          // -3 is marked incorrect
          // -4 is clicked incorrect
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
          child: Text(getContent(state[i])),
          onPressed: state[i] <= 0 ? () {
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
          } : null,
      ),
      )
    )
    );
    return new Center(
      // child: CustomPaint(
        child: GridView.count(
          crossAxisCount: N,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          padding: const EdgeInsets.only(left: 7, right: 7, top: 7, bottom: 30),
          children: buttons.toList(),
        ),
      // ),
    );
  }
}
