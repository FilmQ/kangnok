import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/parks/announcement.dart';
import 'package:kangnok/models/parks/park.dart';
import 'package:kangnok/models/parks/review.dart';
import 'package:kangnok/models/roles/explorer.dart';
import 'package:kangnok/models/roles/ranger.dart';
import 'package:kangnok/providers/user_provider.dart';
import 'package:kangnok/services/announcement_service.dart';
import 'package:kangnok/services/checkin_service.dart';
import 'package:kangnok/services/ranger_service.dart';
import 'package:kangnok/services/review_service.dart';

// i think this file is a bit long but idk man
class ExplorerParkPage extends ConsumerStatefulWidget {
  const ExplorerParkPage({super.key});

  @override
  ConsumerState<ExplorerParkPage> createState() => _ExplorerParkPageState();
}

class _ExplorerParkPageState extends ConsumerState<ExplorerParkPage> {
  int _currentPage = 0;
  final int _totalPages = 2;
  Stream<QuerySnapshot>? _announcementService;
  Stream<QuerySnapshot>? _reviewService;
  Stream<QuerySnapshot>? _rangerService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_announcementService == null ||
        _reviewService == null ||
        _rangerService == null) {
      final park = ModalRoute.of(context)!.settings.arguments as Park?;
      if (park?.id != null) {
        _announcementService = AnnouncementService().getAnnouncementsFromPark(
          park!.id!,
        );
        _reviewService = ReviewService().getReviewsFromPark(park.id!);
        _rangerService = RangerService().getRangersFromPark(park.id!);
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

  Widget _buildImageGrid(List<String> imageUrls) {
    const double gap = 2;
    const double gridHeight = 200;

    Widget image(String url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (imageUrls.length == 1) {
      return SizedBox(
        height: gridHeight,
        width: double.infinity,
        child: image(imageUrls[0]),
      );
    }

    if (imageUrls.length == 2) {
      return SizedBox(
        height: gridHeight,
        child: Row(
          children: [
            Expanded(child: image(imageUrls[0])),
            SizedBox(width: gap),
            Expanded(child: image(imageUrls[1])),
          ],
        ),
      );
    }

    if (imageUrls.length == 3) {
      return SizedBox(
        height: gridHeight,
        child: Row(
          children: [
            Expanded(child: image(imageUrls[0])),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: image(imageUrls[1])),
                  SizedBox(height: gap),
                  Expanded(child: image(imageUrls[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4+ images: 2x2 grid
    final remaining = imageUrls.length - 4;
    return SizedBox(
      height: gridHeight,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: image(imageUrls[0])),
                SizedBox(height: gap),
                Expanded(child: image(imageUrls[2])),
              ],
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              children: [
                Expanded(child: image(imageUrls[1])),
                SizedBox(height: gap),
                Expanded(
                  child: remaining > 0
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            image(imageUrls[3]),
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Text(
                                  '+$remaining',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : image(imageUrls[3]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(Park park) async {
    final user = ref.read(currentUserProvider).value;
    final uid = user?.uid;
    if (uid == null || park.id == null) return;

    final result = await CheckInService().checkIn(
      uid: uid,
      parkId: park.id!,
      parkCoordinate: park.coordinate,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? ''),
        backgroundColor: result.isSuccess
            ? Colors.green
            : result.isAlreadyVisited
            ? Colors.orange
            : Colors.red,
      ),
    );
  }

  Widget _buildReviewTab(Park park) {
    final user = ref.read(currentUserProvider).value as Explorer;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Spacer(),
              ElevatedButton(
                onPressed: user.parkVisited.contains(park.name)
                    ? () {
                        Navigator.pushNamed(
                          context,
                          "/explorer_add_post",
                          arguments: park.id,
                        );
                      }
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Check in required"),
                              content: Text(
                                "You must check in to this park first before posting a review.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                ),
                child: Text("Post a review"),
              ),
              IconButton(
                icon: Icon(Icons.sort),
                tooltip: "Sort reviews",
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(child: _buildUserReviewElements()),
      ],
    );
  }

  Widget _buildRangerTab() {
    return StreamBuilder(
      stream: _rangerService,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Center(
            child: Center(
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
            ),
          );
        }

        if (snapshot.hasData) {
          final rangers = snapshot.data?.docs ?? [];

          if (rangers.isEmpty) {
            return Center(
              child: Text(
                "No rangers for this park are announced as of yet",
                textAlign: .center,
              ),
            );
          }

          return ListView.builder(
            itemCount: rangers.length,
            itemBuilder: (context, index) {
              final ranger = Ranger.fromJson(
                rangers[index] as Map<String, dynamic>,
                id: rangers[index].id,
              );
              return Center(
                child: Card(
                  child: Row(
                    children: [
                      if (ranger.profileImageUrl != null)
                        Image.network(ranger.profileImageUrl!),
                      Text(ranger.title),
                      Text(ranger.email),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Center(
          child: Text(
            "This shouldn't happen, \nbut we couldn't load the rangers right now!",
            textAlign: .center,
          ),
        );
      },
    );
  }

  Widget _buildUserReviewElements() {
    final uid = ref.watch(currentUserProvider).value?.uid;

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
              final isLiked = review.likedBy.contains(uid);
              final isAuthor = review.authorId == uid;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (review.imageUrls != null &&
                        review.imageUrls!.isNotEmpty)
                      _buildImageGrid(review.imageUrls!),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.authorName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(review.content),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (uid != null && review.id != null) {
                                    ReviewService().toggleLike(review.id!, uid);
                                  }
                                },
                                icon: Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  color: isLiked ? Colors.blue : null,
                                ),
                              ),
                              Text(review.likeCount.toString()),
                              Spacer(),
                              if (isAuthor)
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Delete Review"),
                                        content: Text(
                                          "Are you sure you want to delete this review?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && review.id != null) {
                                      await ReviewService().deleteReview(
                                        review.id!,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Delete review",
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                actions: [
                  IconButton(
                    onPressed: () => _checkIn(park),
                    icon: Icon(Icons.location_on),
                    tooltip: "Check in",
                  ),
                ],
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
          body: TabBarView(
            children: [
              _buildAnnouncementTab(),
              _buildDescriptionTab(park!),
              _buildReviewTab(park),
              _buildRangerTab(),
            ],
          ),
        ),
      ),
    );
  }
}
