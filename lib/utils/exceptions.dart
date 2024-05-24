class EmailAlreadyExistException implements Exception {
  final String message;

  EmailAlreadyExistException(this.message);
}

class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException(this.message);
}

class IncorrectPasswordOrUserNotFound implements Exception {
  final String message;

  IncorrectPasswordOrUserNotFound(this.message);
}
