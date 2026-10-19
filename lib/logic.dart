// ignore_for_file: avoid_print
void main(List<String> args) {
  if (args.isNotEmpty) {
    print("${args[0]} is prime or not ? ${isPrime(int.parse(args[0]))}");
  }
}

bool isPalindrome({required String parameter}) {
  final realWord = parameter.toLowerCase();
  return realWord == realWord.split('').reversed.join();
}

void fizzBuzz(int max) {
  for (var i = 1; i <= max; i++) {
    if (i % 15 == 0) {
      print("$i is FizzBuzz");
    } else if (i % 3 == 0) {
      print("$i is Fizz");
    } else if (i % 5 == 0) {
      print("$i is Buzz");
    }
  }
}

bool isPrime(int param) {
  if (param < 2) return false;

  for (var i = 2; i * i <= param; i++) {
    if (param % i == 0) return false;
  }
  return true;
}