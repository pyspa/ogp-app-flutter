import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'http.dart';


void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OGP.app',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(title: 'OGP.app'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ChangeNotifierProvider<PostModel>(
              create: (context) => PostModel(),
              child: PostForm(),
            )
          ],
        ),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final TextEditingController _controller = new TextEditingController();

  Widget build(BuildContext context) {
    return Consumer<PostModel>(builder: (context, model, _) {
      return Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                enabled: true,
                obscureText: false,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "What's happening?",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        model.clear();
                        _controller.clear();
                      }),
                ),
                onChanged: model.setInput,
                onSubmitted: (_) async {
                  if (model.words.isEmpty) {
                    return;
                  }
                  try {
                    var url = await _loading(model.post);
                    debugPrint("share: $url");
                    final RenderBox box = context.findRenderObject();
                    Share.share(url,
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  } catch (e) {
                    _showDialog(e.toString());
                  } finally {
                    _controller.clear();
                  }
                },
              ),
              SizedBox(height: 40),
              FloatingActionButton.extended(
                  icon: const Icon(Icons.add),
                  label: Text("OGP !!!"),
                  onPressed: () async {
                    if (model.words.isEmpty) {
                      return;
                    }
                    try {
                      var url = await _loading(model.post);
                      debugPrint("share: $url");
                      final RenderBox box = context.findRenderObject();
                      Share.share(url,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    } catch (e) {
                      _showDialog(e.toString());
                    } finally {
                      _controller.clear();
                    }
                  }),
              SizedBox(height: 40),
              Text("@ 2020 Powered by pyspa."),
            ],
          ));
    });
  }

  Future<String> _loading(PostCallback f) {
    const size = 120.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: const Center(
                child: SizedBox(
              child: CircularProgressIndicator(),
              height: size,
              width: size,
            )));
      },
    );

    try {
      return f();
    } finally {
      new Future.delayed(new Duration(milliseconds: 100), () {
        Navigator.pop(context);
      });
    }
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Failed"),
          content: new Text(text),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
