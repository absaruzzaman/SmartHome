import 'dart:math';

class IdGen {
  static final Random _rng = Random.secure();

  static String _base36(int n) {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    if (n == 0) return '0';
    var x = n.abs();
    final sb = StringBuffer();
    while (x > 0) {
      sb.write(chars[x % 36]);
      x ~/= 36;
    }
    return sb.toString().split('').reversed.join();
  }

  static String _rand(int len) {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final sb = StringBuffer();
    for (int i = 0; i < len; i++) {
      sb.write(chars[_rng.nextInt(chars.length)]);
    }
    return sb.toString();
  }

  static String room() {
    final t = DateTime.now().microsecondsSinceEpoch;
    return 'r_${_base36(t)}_${_rand(4)}';
  }

  static String device() {
    final t = DateTime.now().microsecondsSinceEpoch;
    return 'd_${_base36(t)}_${_rand(4)}';
  }
}
