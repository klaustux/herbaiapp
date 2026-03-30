class Herbas {
  final int id;
  final String name;
  final String herbasName;
  final String type;
  final String county;
  final String file;
  final bool isSvg;

  const Herbas({
    required this.id,
    required this.name,
    required this.herbasName,
    required this.type,
    required this.county,
    required this.file,
    required this.isSvg,
  });

  factory Herbas.fromJson(Map<String, dynamic> json) {
    return Herbas(
      id: json['id'] as int,
      name: json['name'] as String,
      herbasName: json['herbasName'] as String,
      type: json['type'] as String,
      county: json['county'] as String,
      file: json['file'] as String,
      isSvg: json['isSvg'] as bool,
    );
  }

  String get assetPath => 'assets/herbai/$file';
}

class HerbasType {
  static const miestas = 'Miestas';
  static const rajonas = 'Rajonas';
  static const savivaldybe = 'Savivaldybė';
  static const seniunija = 'Seniūnija';
  static const kita = 'Kita';

  static const List<String> all = [
    miestas,
    rajonas,
    savivaldybe,
    seniunija,
    kita,
  ];
}
