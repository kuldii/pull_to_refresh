import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  var faker = new Faker();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RefreshController refreshC = RefreshController();

  List<User> allUsers = [];

  void refreshData() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      allUsers.clear();
      initData();
      setState(() {});
      refreshC.refreshCompleted();
    } catch (e) {
      refreshC.refreshFailed();
    }
  }

  void loadData() async {
    try {
      await Future.delayed(Duration(seconds: 1));

      if (allUsers.length >= 35) {
        // stop gaada user di database .... sudah abis datanya
        refreshC.loadNoData();
      } else {
        initData();
        setState(() {});
        refreshC.loadComplete();
      }
    } catch (e) {
      refreshC.loadFailed();
    }
  }

  void initData() {
    for (var i = 0; i < 15; i++) {
      allUsers.add(User(name: faker.person.name(), email: faker.internet.email()));
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pull to Refresh"),
      ),
      body: SmartRefresher(
        controller: refreshC,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: refreshData,
        // header: WaterDropHeader(
        //   complete: Text("INI COMPLETE"),
        //   failed: Text("INI FAILED"),
        //   refresh: Text("INI REFRESH"),
        //   waterDropColor: Colors.red,
        // ),
        footer: CustomFooter(
          builder: (context, mode) {
            if (mode == LoadStatus.idle) {
              return Center(child: Text("pull up load"));
            } else if (mode == LoadStatus.loading) {
              return Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (mode == LoadStatus.failed) {
              return Center(child: Text("Load Failed!Click retry!"));
            } else if (mode == LoadStatus.canLoading) {
              return Center(child: Text("release to load more"));
            } else {
              return Center(child: Text("No more Data"));
            }
          },
        ),
        onLoading: loadData,
        child: ListView.builder(
          itemCount: allUsers.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              child: Text("${index + 1}"),
            ),
            title: Text("${allUsers[index].name}"),
            subtitle: Text("${allUsers[index].email}"),
          ),
        ),
      ),
    );
  }
}

class User {
  late String name;
  late String email;

  User({required this.name, required this.email});
}
