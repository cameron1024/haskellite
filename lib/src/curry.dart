
/// Converts a binary function into a unary function that returns a unary function.
///
/// Enables the use of partial application of functions.
/// This often leads to more concise function declarations
///
/// For example:
/// ```dart
/// final addFunction = (int a, int b) => a + b;
/// final add = curry(addFunction);
///
/// [1, 2, 3].map(add(1))  // returns [2, 3, 4]
/// ```
C Function(B) Function(A) curry<A, B, C>(C Function(A, B) function) {
  return (A a) => (B b) => function(a, b);
}

/// Converts a unary function that returns a unary function into a binary function
///
/// For example:
/// ```dart
/// final function = (int a) => (int b) => a + b;
/// final uncurried = uncurry(function);
/// uncurried(2, 3)  // returns 5
/// ```
C Function(A, B) uncurry<A, B, C>(C Function(B) Function(A) function) {
  return (A a, B b) => function(a)(b);
}

/// Swaps the order of arguments of an uncurried function.
///
/// For example:
/// ```dart
/// final function = (String s, int i) => '$s, $i';
/// function('hello', 2)  // returns 'hello, 2'
///
/// final swapped = swapUncurried(function);
///
/// ```
C Function(B, A) swapU<A, B, C>(C Function(A, B) function) => (B b, A a) => function(a, b);

/// Swaps the order of arguments of a curried function.
///
/// For example:
/// ```dart
/// subtract(3)(4)  // returns 1
///
/// final swapped = swapUncurried(subtract);
/// swapped(3)(4)  // returns -1
/// ```
C Function(A) Function(B) swap<A, B, C>(C Function(B) Function(A) function) => (B b) => (A a) => function(a)(b);

/// Curried function to add numbers
///
/// For example:
/// ```dart
/// [1, 2, 3].map(add(1))  // returns [2, 3, 4]
/// ```
num Function(num) add(num a) => (b) => a + b;

/// Curried function to subtract numbers
///
/// For example:
/// ```dart
/// [1, 2, 3].map(subtract(1))  // returns [0, 1, 2]
/// ```
num Function(num) subtract(num a) => (b) => b - a;

/// Curried function to multiply numbers
///
/// For example:
/// ```dart
/// [1, 2, 3].map(multiply(2))  // returns [2, 4, 6]
/// ```
num Function(num) multiply(num a) => (b) => a * b;

/// Curried function to divide numbers
///
/// For example:
/// ```dart
/// [2, 4, 6].map(divide(2))  // returns [1, 2, 3]
/// ```
num Function(num) divide(num a) => (b) => b / a;

/// Curried function to mod numbers
///
/// For example:
/// ```dart
/// [3, 4, 5].map(mod(3))  // returns [0, 1, 2]
/// ```
num Function(num) mod(num a) => (b) => b % a;

/// Curried function to concatenate strings
///
/// For example:
/// ```dart
/// [3, 4, 5].map(mod(3))  // returns [0, 1, 2]
/// ```
String Function(String) concat(String a) => (b) => '$b$a';
