import 'package:flutter/material.dart';
import '../data/data_define.dart';

Map<ShaResultType, Icon> shaResultMap = {
  ShaResultType.atari: const Icon(Icons.panorama_fish_eye),
  ShaResultType.hazure: const Icon(Icons.clear),
  ShaResultType.shitsu: const Icon(Icons.subdirectory_arrow_right),
  ShaResultType.fumei: const Icon(Icons.question_mark),
  ShaResultType.nashi: const Icon(Icons.minimize),
  ShaResultType.delete: const Icon(Icons.delete),
};

Map<ShaResultType, String> shaResultString = {
  ShaResultType.atari: "○",
  ShaResultType.hazure: "×",
  ShaResultType.shitsu: "失",
  ShaResultType.fumei: "？",
  ShaResultType.nashi: "－",
  ShaResultType.delete: "",
};