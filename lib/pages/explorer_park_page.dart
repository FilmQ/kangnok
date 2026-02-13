import 'package:flutter/material.dart';
import 'package:kangnok/models/parks/park.dart';

// TODO: add the park's functionality here
class ExplorerParkPage extends StatefulWidget {
  const ExplorerParkPage({super.key});

  @override
  State<ExplorerParkPage> createState() => _ExplorerParkPageState();
}

class _ExplorerParkPageState extends State<ExplorerParkPage> {
  int _currentPage = 0;
  final int _totalPages = 2;

  // This function builds a widget that creates the green dot image locator.
  Widget _placeImageLocatorDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 10 : 8,
          height: _currentPage == index ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = ModalRoute.of(context)!.settings.arguments as Park?;
    final parkName = park?.name ?? "Park's page";
    final imgLocation = "assets/parks/";
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(parkName),
                expandedHeight: 450,
                floating: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 50,
                      ), // TabBar height
                      child: Column(
                        children: [
                          const SizedBox(height: 56), // AppBar height
                          Expanded(
                            child: PageView(
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              // ALSO YET ANOTHER PLACEHOLDER DATA.
                              children: [
                                Image.asset(
                                  "${imgLocation}grand-canyon.jpg",
                                  fit: BoxFit.cover,
                                ),
                                Image.asset(
                                  "${imgLocation}pnw.png",
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _placeImageLocatorDots(),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ),

                bottom: TabBar(
                  labelStyle: TextStyle(fontSize: 18),
                  splashBorderRadius: BorderRadius.all(Radius.circular(10)),
                  tabs: [
                    Tab(height: 50, text: "ประกาศ"),
                    Tab(height: 50, text: "ภาพรวม"),
                    Tab(height: 50, text: "รีวิว"),
                    Tab(height: 50, text: "เจ้าหน้าที่"),
                  ],
                ),
              ),
            ];
          },
          // PLACEHOLDER DATA. CHANGE LATER.
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    ListTile(title: Text("Announcement ${index + 1}")),
              ),
              ListView(children: [ListTile(title: Text("Overview content"))]),
              ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    ListTile(title: Text("Review ${index + 1}")),
              ),
              ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text("${index + 1}")),
                  title: Text("Ranger ${index + 1}"),
                  subtitle: Text("Station staff"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
