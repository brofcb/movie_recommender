import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_recommender/models/movie.dart';
import 'package:movie_recommender/widgets/input_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.red),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String movieName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Movie Recommender",
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
            ),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 35,
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Enter a movie name to get recommendations",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: InputTextField(
                            onChanged: (s) => {
                              setState(() {
                                movieName = s;
                              })
                            },
                            hintText: "Enter a movie",
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward),
        backgroundColor: Colors.red,
        onPressed: () => {
          if (movieName != "")
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecondPage(
                          movieName: movieName,
                        )),
              )
            }
        },
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.movieName}) : super(key: key);
  final String movieName;
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  Future<List<Movie>>? movies;
  initState() {
    super.initState();
    print("init");
    movies = fetchMovies(widget.movieName);
  }

  Future<List<Movie>> fetchMovies(String movieName) async {
    print("Fetching");
    List<Movie> movies = <Movie>[];
    final response = await http.get(Uri.parse(
        "https://us-central1-unique-bebop-342715.cloudfunctions.net/knn_model?movie=$movieName"));
    print(response.body);
    print("Hello");
    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      for (var movie in json["data"]) {
        movies.add(Movie(name: movie));
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load movie');
    }
    return movies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Recommended Movies",
          ),
          backgroundColor: Colors.red),
      body: Center(
          child: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Movie>> snapshot,
        ) {
          if (snapshot.hasData) {
            return (ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, i) {
                Movie mov = snapshot.data![i];
                return ListTile(
                  title: Text(mov.name),
                );
              },
            ));
          } else {
            return (CircularProgressIndicator());
          }
        },
      )),
    );
  }
}
