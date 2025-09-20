// lib/data/th_cities.dart
class THCity {
  final String name;   // ชื่อเมือง/จังหวัด
  final double lat;    // ละติจูด
  final double lon;    // ลองจิจูด
  const THCity(this.name, this.lat, this.lon);
}

/// เมืองตัวอย่างเดิม (ไว้ให้แอปใช้งานได้ทันที)
const thCities = <THCity>[
  THCity('Bangkok', 13.7563, 100.5018),
  THCity('Chiang Mai', 18.7883, 98.9853),
  THCity('Phuket', 7.8804, 98.3923),
  THCity('Khon Kaen', 16.4419, 102.8350),
  THCity('Udon Thani', 17.3647, 102.8158),
  THCity('Hat Yai', 7.0086, 100.4747),
];

/// จังหวัด "ภาคเหนือ" (เหนือ + เหนือตอนล่าง 17 จังหวัด)
/// พิกัดเป็นตำแหน่งตัวเมืองของแต่ละจังหวัด เหมาะกับการเรียกพยากรณ์ระดับจังหวัด
const thNorthernProvinces = <THCity>[
  // เหนือตอนบน (8 จังหวัด)
  THCity('เชียงใหม่ (Chiang Mai)', 18.7883, 98.9853),
  THCity('เชียงราย (Chiang Rai)', 19.9105, 99.8406),
  THCity('ลำพูน (Lamphun)', 18.5733, 99.0087),
  THCity('ลำปาง (Lampang)', 18.2889, 99.4928),
  THCity('แม่ฮ่องสอน (Mae Hong Son)', 19.3013, 97.9685),
  THCity('น่าน (Nan)', 18.7750, 100.7710),
  THCity('พะเยา (Phayao)', 19.1667, 99.9010),
  THCity('แพร่ (Phrae)', 18.1459, 100.1410),

  // เหนือตอนล่าง (9 จังหวัด)
  THCity('อุตรดิตถ์ (Uttaradit)', 17.6200, 100.0990),
  THCity('พิษณุโลก (Phitsanulok)', 16.8211, 100.2659),
  THCity('สุโขทัย (Sukhothai)', 17.0078, 99.8236),
  THCity('ตาก (Tak)', 16.8699, 99.1250),
  THCity('กำแพงเพชร (Kamphaeng Phet)', 16.4827, 99.5228),
  THCity('นครสวรรค์ (Nakhon Sawan)', 15.7047, 100.1372),
  THCity('พิจิตร (Phichit)', 16.4390, 100.3480),
  THCity('เพชรบูรณ์ (Phetchabun)', 16.4190, 101.1590),
  THCity('อุทัยธานี (Uthai Thani)', 15.3835, 100.0240),
];

/// (ทางเลือก) รวมจังหวัดภาคเหนือเข้ากับรายการหลักไว้ให้เลือกใน Dropdown เดียว
const thCitiesWithNorthern = <THCity>[
  ...thCities,
  ...thNorthernProvinces,
];
