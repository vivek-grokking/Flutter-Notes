// login view exceptions
class UserNotFoundException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register view exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidEmailException implements Exception {}

// generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}
