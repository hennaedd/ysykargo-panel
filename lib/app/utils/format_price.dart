String formatPrice(
  dynamic price, {
  double complementaryItemsTotalPrice = 0,
}) {
  if (price is String) {
    price = double.tryParse(price.replaceAll(RegExp('[^0-9,.]'), '').replaceAll(',', '.'));
  }

  if (price == null) {
    return '0 ₺';
  }

  double totalPrice = price + complementaryItemsTotalPrice;
  totalPrice = double.parse(totalPrice.toStringAsFixed(2));

  String formattedPrice = totalPrice.toString();
  final List<String> parts = formattedPrice.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '00';

  integerPart = _handleWriteIntegerPriceMoreThan1000(int.parse(integerPart));

  decimalPart = decimalPart.padRight(2, '0'); 

  formattedPrice = '$integerPart,$decimalPart ₺';

  return formattedPrice;
}

String _handleWriteIntegerPriceMoreThan1000(int input) {
  final List<String> parts = [];
  final int partCount = (input.toString().length / 3).ceil();
  final int integerLength = input.toString().length;

  for (int i = partCount - 1; i >= 0; i--) {
    int start = integerLength - (i + 1) * 3;
    final int end = integerLength - i * 3;
    if (start < 0) {
      start = 0;
    }
    parts.add(input.toString().substring(start, end));
  }

  return parts.join('.');
}
