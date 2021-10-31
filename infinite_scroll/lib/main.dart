import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() => runApp( MaterialApp(
    home: InfiniteScroll(),
  ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      debugShowCheckedModeBanner: false,
      home: InfiniteScroll(),
    );
  }
}

class InfiniteScroll extends StatefulWidget {
  const InfiniteScroll({Key? key}) : super(key: key);

  @override
  _InfiniteScrollState createState() => _InfiniteScrollState();
}

class _InfiniteScrollState extends State<InfiniteScroll> {
  int currentPage = 0;
  late int totalPages;
  final RefreshController refreshController =  RefreshController(initialRefresh: true);
  List<dynamic> newdata = [];
  List<dynamic> name = [];
  List<dynamic> url = [];

  Future<bool> makeNetworkCall({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 0;
    }
    var _dio = Dio();
    await _dio
        .get('https://pokeapi.co/api/v2/pokemon?offset=$currentPage&limit=20')
        .then((response) {
      //print('${response.data}');
      List results = response.data['results'];
      if (isRefresh){
        newdata = results;
      }else {
        newdata.addAll(response.data['results']);
      }
      currentPage+=20;
      totalPages  = results.length;
      newdata = results;
      print(newdata);
      List<String> names = newdata.map((e) => e["name"].toString()).toList();
      List<String> urls = newdata.map((e) => e["url"].toString()).toList();
      print(names);
      setState(() {
        name = names;
        url = urls;
      });
    }).catchError((e) {});
    print('error');
    return true;
  }

  @override
  void initState() {
    super.initState();
      makeNetworkCall();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scroll Page',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12.0,
            letterSpacing: 1.0,
          ),),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh:() async {
          final result = await makeNetworkCall(isRefresh: true);
          if(result){
            refreshController.refreshCompleted();
          }else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await makeNetworkCall();
          if(result){
            refreshController.loadComplete();
          }else {
            refreshController.loadFailed();
          }
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                name[index],
                style: TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2
                ),
              ),
              subtitle: Text(url[index],
                  style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2
                  )),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: newdata.length,
        ),
      ),
    );
  }
}

