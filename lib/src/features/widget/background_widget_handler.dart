import 'package:wake_on_lan/wake_on_lan.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri != null) {
    if (uri.scheme == 'wol' && uri.host == 'wake') {
      // Parse params
      final macStr = uri.queryParameters['mac'];
      final portStr = uri.queryParameters['port'];

      if (macStr != null && MACAddress.validate(macStr).state) {
        final mac = MACAddress(macStr);
        final port = int.tryParse(portStr ?? '9') ?? 9;
        final ipv4 = IPAddress('255.255.255.255');

        await WakeOnLAN(ipv4, mac, port: port).wake();
        print("Sent WoL to $macStr on port $port via widget");
      }
    }
  }
}
