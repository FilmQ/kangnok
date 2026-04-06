import 'dart:async';
import 'package:flutter/material.dart';

class PromoteParkBox extends StatefulWidget {
  const PromoteParkBox({super.key});

  @override
  State<PromoteParkBox> createState() => _PromoteParkBoxState();
}

class _PromoteParkBoxState extends State<PromoteParkBox> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Mock รูปภาพอุทยาน (คุณสามารถเปลี่ยนเป็น URL จริงจาก Firebase ได้ในอนาคต)
  final List<String> _bannerImages = [
    'https://firebasestorage.googleapis.com/v0/b/kangnok-232fa.firebasestorage.app/o/parks%2Fbua_tong_waterfall_seven_colors_spring%2Ffront_page_images%2Fbuatong_sign.jpg?alt=media&token=587891f5-926d-42af-876b-3cc4f503bc19', 
    'https://firebasestorage.googleapis.com/v0/b/kangnok-232fa.firebasestorage.app/o/parks%2Fbua_tong_waterfall_seven_colors_spring%2Ffront_page_images%2Fpond1-fpi.jpeg?alt=media&token=32a881c1-c6ff-458a-8c09-e1060fd32cc6', 
    'https://firebasestorage.googleapis.com/v0/b/kangnok-232fa.firebasestorage.app/o/parks%2Fbua_tong_waterfall_seven_colors_spring%2Ffront_page_images%2Fwaterfall1-fpi.jpg?alt=media&token=d553efea-20b7-435e-9ad7-f1fce341e228',
  ];

  @override
  void initState() {
    super.initState();
    // ตั้งเวลาให้เลื่อนทุกๆ 3 วินาที
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // กลับไปรูปแรก
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ยกเลิก Timer เมื่อปิดหน้าจอเพื่อป้องกัน Memory Leak
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // กรอบใส่รูป
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(_bannerImages[index]),
                    fit: BoxFit.cover, // ให้รูปเต็มกรอบ
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                // ใส่ตัวหนังสือทับบนรูป (ถ้าต้องการ)
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: const Text("Featured Park", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // !!!CHANGE TO NAME OF PARK!!!
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // จุด Indicator (จุดกลมๆ บอกว่าอยู่หน้าไหน)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8, // จุดที่เลือกจะยาวกว่า
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}