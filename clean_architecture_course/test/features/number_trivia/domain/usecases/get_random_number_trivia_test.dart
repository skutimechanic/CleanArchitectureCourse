import 'package:clean_architecture_course/core/usecases/usecase.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/enities/number_trivia.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_random_number_trivia_test.mocks.dart';

class NumberTriviaRepositoryTest extends Mock
    implements NumberTriviaRepository {}

@GenerateMocks([NumberTriviaRepositoryTest])
void main() {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepositoryTest mockNumberTriviaRepositoryTest;

// run before every test
  setUp(() {
    mockNumberTriviaRepositoryTest = MockNumberTriviaRepositoryTest();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepositoryTest);
  });

  const tNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test(
    'should get trivia from the repository',
    () async {
      // arrange
      when(mockNumberTriviaRepositoryTest.getRandomNumberTrivia())
          .thenAnswer((_) async => const Right(tNumberTrivia));
      // act
      final result = await usecase(NoParams());
      // assert
      // UseCase should simply return whatever was returned from the Repository
      expect(result, const Right(tNumberTrivia));
      // Verify that the method has been called on the Repository
      verify(mockNumberTriviaRepositoryTest.getRandomNumberTrivia());
      // Only the above method should be called and nothing more.
      verifyNoMoreInteractions(mockNumberTriviaRepositoryTest);
    },
  );
}
