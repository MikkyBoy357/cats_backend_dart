// ignore_for_file: avoid_print

void printRed(Object message) {
  print('\x1B[31m$message\x1B[0m');
}

void printYellow(Object message) {
  print('\x1B[33m$message\x1B[0m');
}

void printGreen(Object message) {
  print('\x1B[32m$message\x1B[0m');
}

void printBlue(Object message) {
  print('\x1B[34m$message\x1B[0m');
}

void printMagenta(Object message) {
  print('\x1B[35m$message\x1B[0m');
}
