import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/models/parks/announcement.dart';
import 'package:kangnok/models/parks/park.dart';
import 'package:kangnok/models/parks/review.dart';
import 'package:kangnok/services/announcement_service.dart';
import 'package:kangnok/services/review_service.dart';

// TODO: by order:
// TODO: add the park's functionality here
// TODO: connect the park to firebase storage AND firestore
// TODO: refine the park's look
class ExplorerParkPage extends StatefulWidget {
  const ExplorerParkPage({super.key});

  @override
  State<ExplorerParkPage> createState() => _ExplorerParkPageState();
}

class _ExplorerParkPageState extends State<ExplorerParkPage> {
  int _currentPage = 0;
  final int _totalPages = 2;
  Stream<QuerySnapshot>? _announcementService;
  Stream<QuerySnapshot>? _reviewService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_announcementService == null || _reviewService == null) {
      final park = ModalRoute.of(context)!.settings.arguments as Park?;
      if (park?.id != null) {
        _announcementService = AnnouncementService().getAnnouncementsFromPark(
          park!.id!,
        );
        _reviewService = ReviewService().getReviewsFromPark(park.id!);
      }
    }
  }

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

  List<Widget> _buildFrontPagePictures(Park park) {
    return park.imageUrl
        .where((url) => url.isNotEmpty)
        .map<Widget>((url) => Image.network(url, fit: BoxFit.cover))
        .toList();
  }

  Widget _buildDescriptionTab(Park park) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Overview", style: TextStyle(fontSize: 30)),
                SizedBox(height: 5),
                Text(park.description),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Business Hours", style: TextStyle(fontSize: 30)),
                SizedBox(height: 5),
                Text(
                  park.businessHour.isNotEmpty
                      ? park.businessHour
                      : 'No business hours available',
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location", style: TextStyle(fontSize: 30)),
                SizedBox(height: 5),
                Text(park.location),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Coordinate", style: TextStyle(fontSize: 30)),
                SizedBox(height: 5),
                Text(park.coordinate),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Faunas", style: TextStyle(fontSize: 30)),
                SizedBox(height: 10),
                ...park.faunas.map(
                  (fauna) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: fauna.imageUrl.isNotEmpty
                                    ? Image.network(
                                        fauna.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: Icon(
                                          Icons.pets,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fauna.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    fauna.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Floras", style: TextStyle(fontSize: 30)),
                SizedBox(height: 10),
                ...park.floras.map(
                  (flora) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: flora.imageUrl.isNotEmpty
                                    ? Image.network(
                                        flora.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: Icon(
                                          Icons.local_florist,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flora.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    flora.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementTab() {
    return StreamBuilder(
      stream: _announcementService,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("An error occured attempting to load announcements"),
          );
        }
        if (snapshot.hasData) {
          final announcements = snapshot.data?.docs ?? [];

          if (announcements.isEmpty) {
            return Center(child: Text("No announcement has been made yet!"));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = Announcement.fromJson(
                announcements[index].data() as Map<String, dynamic>,
                id: announcements[index].id,
              );

              return Card(
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    Text(announcement.title),
                    Text(announcement.rangerName),
                    Text(announcement.content),
                    Text(announcement.createdAt.toString()),
                  ],
                ),
              );
            },
          );
        }
        return Text(
          "This shouldn't happen, but we can't fetch the announcements.",
        );
      },
    );
  }

  Widget _buildReviewTab() {
    return StreamBuilder(
      stream: _reviewService,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(
            child: Card(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Icon(Icons.warning),
                  Text(
                    "We cannot load the reviews right now. Sorry for the inconvenience!",
                    textAlign: .center,
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          final reviews = snapshot.data?.docs ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Text("Be the first person to review this place!"),
            );
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = Review.fromJson(
                reviews[index].data() as Map<String, dynamic>,
                id: reviews[index].id,
              );
              return Card(
                child: Row(
                  children: [
                    Text(review.authorName),
                    Text(review.content),
                    Text(review.likeCount.toString()),
                  ],
                ),
              );
            },
          );
        }

        return Center(
          child: Text(
            "This shouldn't happen... but we couldn't load the reviews",
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = ModalRoute.of(context)!.settings.arguments as Park?;
    final parkName = park?.name ?? "Park's page";
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
                              children: _buildFrontPagePictures(park),
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
              _buildAnnouncementTab(),
              _buildDescriptionTab(park!),
              _buildReviewTab(),
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
