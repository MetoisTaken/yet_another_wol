import 'package:flutter/services.dart';

class MacAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // Remove any character that is not a hex digit
    text = text.replaceAll(RegExp(r'[^a-fA-F0-9]'), '');

    // Limit to 12 hex digits (which makes 17 chars with colons)
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
        buffer.write(text[i]);
        // Add colon after every 2nd char, but not at the end
        if ((i + 1) % 2 == 0 && (i + 1) != text.length) {
          buffer.write(':');
        }
    }

    var string = buffer.toString().toUpperCase();
    
    // Calculate new cursor position
    // Simple approach: put cursor at end. 
    // For better experience we might want to preserve relative position but for MAC address usually typing from left to right.
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
