import 'package:flutter/material.dart';
import '../data/data_define.dart';
import 'my_flutter_app_icons.dart';

Map<ShaResultType, Icon> shaResultMap = {
  ShaResultType.atari: const Icon(Icons.panorama_fish_eye),
  ShaResultType.hazure: const Icon(Icons.clear),
  ShaResultType.shitsu: const Icon(SitsuIcon.sitsu),
  ShaResultType.fumei: const Icon(Icons.question_mark),
  ShaResultType.nashi: const Icon(Icons.minimize),
  ShaResultType.delete: const Icon(Icons.delete),
};

Map<ShaResultType, IconData> shaResultIcon = {
  ShaResultType.atari: Icons.panorama_fish_eye,
  ShaResultType.hazure: Icons.clear,
  ShaResultType.shitsu: SitsuIcon.sitsu,
  ShaResultType.fumei: Icons.question_mark,
  ShaResultType.nashi: Icons.minimize,
  ShaResultType.delete: Icons.delete,
};



Map<GyoshaType, String> gyoshaTypeString = {
  GyoshaType.renshu:"練習",
  GyoshaType.shakai:"射会",
  GyoshaType.shiai:"試合",
  GyoshaType.dantai:"団体",
};