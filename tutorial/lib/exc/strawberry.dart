import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ၁။ ဘယ်ဘက်ခြမ်း Column (Title, Description, Ratings, Icons)
    final leftColumn = Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Strawberry Pavlova',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          const Text(
            'Pavlova is a meringue-based dessert named after the Russian ballerina Anna Pavlova. '
            'Pavlova features a crisp crust and soft, light inside, topped with fruit and whipped cream.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, color: Colors.black87, size: 18),
                ),
              ),
              const Text(
                '170 Reviews',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Icons (Prep, Cook, Feeds)
          DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              height: 1.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.kitchen, color: Colors.green[500]),
                    const Text('PREP:'),
                    const Text('25 min'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.timer, color: Colors.green[500]),
                    const Text('COOK:'),
                    const Text('1 hr'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.restaurant, color: Colors.green[500]),
                    const Text('FEEDS:'),
                    const Text('4-6'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ၂။ ညာဘက်ခြမ်း ပုံ
    final mainImage = Image.network(
      'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=800&q=80',
      fit: BoxFit.cover,
    );

    // ၃။ ပင်မ Card Box (Row နဲ့ ဘယ်/ညာ တွဲထားခြင်း)
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown.shade200, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: leftColumn,
            ),
            Expanded(
              flex: 1,
              child: mainImage,
            ),
          ],
        ),
      ),
    );
  }
}