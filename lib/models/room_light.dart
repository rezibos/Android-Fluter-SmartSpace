import 'package:flutter/material.dart';

class RoomLight {
  const RoomLight({
    required this.id,
    required this.name,
    required this.icon,
    required this.isOn,
    required this.brightness,
  });

  final String id;
  final String name;
  final IconData icon;
  final bool isOn;
  final double brightness;

  RoomLight copyWith({bool? isOn, double? brightness}) => RoomLight(
    id: id,
    name: name,
    icon: icon,
    isOn: isOn ?? this.isOn,
    brightness: brightness ?? this.brightness,
  );
}
