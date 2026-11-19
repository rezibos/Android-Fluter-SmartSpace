enum SoilState { wet, normal, dry }

class SensorSnapshot {
  const SensorSnapshot({
    required this.temperature,
    required this.humidity,
    required this.soil,
    required this.rain,
    required this.gas,
    required this.lightStates,
    required this.relayOn,
  });

  factory SensorSnapshot.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    bool state(String key) => number(key) == 1;

    return SensorSnapshot(
      temperature: number('suhu'),
      humidity: number('udara'),
      soil: number('tanah').round(),
      rain: number('hujan').round(),
      gas: number('gas').round(),
      lightStates: {
        'kamar': state('kamar'),
        'tengah': state('tengah'),
        'dapur': state('dapur'),
        'depan': state('depan'),
      },
      relayOn: state('relay'),
    );
  }

  final double temperature;
  final double humidity;
  final int soil;
  final int rain;
  final int gas;
  final Map<String, bool> lightStates;
  final bool relayOn;

  bool get isRaining => rain < 2500;
  bool isGasDanger(int threshold) => gas > threshold;
  SoilState get soilState => soil >= 2800
      ? SoilState.dry
      : soil <= 1600
      ? SoilState.wet
      : SoilState.normal;
}
