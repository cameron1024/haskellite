import 'dart:io';

import 'package:haskellite/haskellite.dart';

/// This example shows how an imaginary login API could be implemented
///
/// For examples on a specific method/function, check the doc comment for that member, most, if not all, have short example uses
void main() async {
  print('example success event');
  handleResult(await login(true));

  print('example failure event');
  handleResult(await login(false));

}

// an example handler function,
void handleResult(Result<User> result) => result.onValue(handleSuccess).onError(handleError);

void handleSuccess(User user) => print('Welcome, ${user.name}');
void handleError(dynamic error) => stderr.writeln(error);

Future<Result<User>> login(bool mockSuccess) async => Result.fromFuture(_callLoginApi(mockSuccess));

// an example api provided through a library, for example, Firebase Auth
Future<User> _callLoginApi(bool mockSuccess) async {
  if (mockSuccess) {
    return Future.value(User('John Smith'));
  }
  return Future.error(Exception('User not found'));
}

class User {
  final String name;
  User(this.name);
}