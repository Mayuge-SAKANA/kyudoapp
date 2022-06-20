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

Map<ShaResultType, IconData> shaResultIcon = {
  ShaResultType.atari: Icons.panorama_fish_eye,
  ShaResultType.hazure: Icons.clear,
  ShaResultType.shitsu: Icons.subdirectory_arrow_right,
  ShaResultType.fumei: Icons.question_mark,
  ShaResultType.nashi: Icons.minimize,
  ShaResultType.delete: Icons.delete,
};



Map<GyoshaType, String> gyoshaTypeString = {
  GyoshaType.renshu:"練習",
  GyoshaType.shakai:"射会",
  GyoshaType.shiai:"試合"
};