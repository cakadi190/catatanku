import 'package:catatanqu/home_tab/about_tab.dart';
import 'package:catatanqu/home_tab/create_note.dart';
import 'package:catatanqu/home_tab/home_page.dart';
import 'package:flutter/material.dart';

GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatatanQu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  bool _shouldRefresh = false;

  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      HomePage(
        key: homePageKey, // Tambahkan key di sini
        onTabChange: _onTabChange,
        shouldRefresh: _shouldRefresh,
        onRefreshComplete: _onRefreshComplete,
      ),
      CreateNote(
        onNoteCreated: _onNoteCreated,
        existingNote: null,
      ),
      const AboutTab(),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onRefreshComplete() {
    setState(() {
      _shouldRefresh = false;
    });
  }

  void _onNoteCreated() {
    setState(() {
      _currentIndex = 0;
      _shouldRefresh = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: _currentIndex == 0
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text('CatatanQu'),
                actions: _currentIndex == 0
                    ? [
                        IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: () {
                            homePageKey.currentState?.refreshData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                        ),
                      ]
                    : null,
              )
            : null,
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.notes),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: 'Buat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Tentang',
            ),
          ],
        ),
      ),
    );
  }
}

