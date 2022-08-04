import 'package:flutter/material.dart';
import '../data/data_define.dart';
import 'my_flutter_app_icons.dart';


Map<ShaResultType, Icon> shaResultMap = {
  ShaResultType.atari: const Icon(Icons.panorama_fish_eye),
  ShaResultType.hazure: const Icon(Icons.clear),
  ShaResultType.shitsu: const Icon(SitsuIcon2.sitsu2),
  ShaResultType.fumei: const Icon(Icons.question_mark),
  ShaResultType.nashi: const Icon(Icons.minimize),
  ShaResultType.delete: const Icon(Icons.delete),


  ShaResultType.ten: const Icon(EntekiNumbers.num_ten),
  ShaResultType.nine: const Icon(EntekiNumbers.num_nine),
  ShaResultType.seven: const Icon(EntekiNumbers.num_seven),
  ShaResultType.five: const Icon(EntekiNumbers.num_five),
  ShaResultType.three: const Icon(EntekiNumbers.num_three),
  ShaResultType.zero: const Icon(EntekiNumbers.num_zero),



};

Map<ShaResultType, Icon> kintekiShaResultMap = {
  ShaResultType.atari: const Icon(Icons.panorama_fish_eye),
  ShaResultType.hazure: const Icon(Icons.clear),
  ShaResultType.shitsu: const Icon(SitsuIcon2.sitsu2),
  ShaResultType.fumei: const Icon(Icons.question_mark),
  ShaResultType.nashi: const Icon(Icons.minimize),
  ShaResultType.delete: const Icon(Icons.delete),
};

Map<ShaResultType, Icon> entekiShaResultMap = {
  ShaResultType.ten: const Icon(EntekiNumbers.num_ten),
  ShaResultType.nine: const Icon(EntekiNumbers.num_nine),
  ShaResultType.seven: const Icon(EntekiNumbers.num_seven),
  ShaResultType.five: const Icon(EntekiNumbers.num_five),
  ShaResultType.three: const Icon(EntekiNumbers.num_three),
  ShaResultType.zero: const Icon(EntekiNumbers.num_zero),
  ShaResultType.delete: const Icon(Icons.delete),
};



Map<GyoshaType, String> gyoshaTypeString = {
  GyoshaType.renshu:"練習",
  GyoshaType.shakai:"射会",
  GyoshaType.shiai:"試合",
  GyoshaType.dantai:"団体",
};