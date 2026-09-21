import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/car.dart';

class CarCard extends StatelessWidget {
  const CarCard({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.blueGrey.shade100,
                image: car.hasPhoto
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(car.photoBase64!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !car.hasPhoto
                  ? const Icon(Icons.directions_car, size: 32, color: Colors.blueGrey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('${car.year} • ${car.version}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(car.plate.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
