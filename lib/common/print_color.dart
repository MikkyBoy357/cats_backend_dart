void printRed(String message) {
  print('\x1B[31m$message\x1B[0m');
}

void printYellow(String message) {
  print('\x1B[33m$message\x1B[0m');
}

void printGreen(String message) {
  print('\x1B[32m$message\x1B[0m');
}
