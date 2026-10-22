import '../models/menu_item.dart';

/// Sample menu used until the owner's real menu is loaded from Firestore.
/// Names and prices are placeholders for the owner to replace.
const sampleMenu = [
  MenuItem(id: 'c1', name: '1pc Chicken with Rice', category: 'Chicken', pricePhp: 99),
  MenuItem(id: 'c2', name: '2pc Chicken with Rice', category: 'Chicken', pricePhp: 179),
  MenuItem(id: 'c3', name: 'Chicken Wings (6pc)', category: 'Chicken', pricePhp: 189),
  MenuItem(id: 'b1', name: 'Bucket of 6', category: 'Buckets', pricePhp: 449),
  MenuItem(id: 'b2', name: 'Bucket of 8', category: 'Buckets', pricePhp: 579),
  MenuItem(id: 'b3', name: 'Party Bucket of 12', category: 'Buckets', pricePhp: 849),
  MenuItem(id: 's1', name: 'Chicken Skin', category: 'Sides', pricePhp: 59),
  MenuItem(id: 's2', name: 'Fries', category: 'Sides', pricePhp: 49),
  MenuItem(id: 's3', name: 'Extra Rice', category: 'Sides', pricePhp: 20),
  MenuItem(id: 'd1', name: 'Iced Tea', category: 'Drinks', pricePhp: 25),
  MenuItem(id: 'd2', name: 'Coke 1.5L', category: 'Drinks', pricePhp: 85, soldOut: true),
];
