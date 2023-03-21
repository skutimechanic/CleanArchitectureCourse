import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture_course/core/error/failures.dart';
import 'package:clean_architecture_course/core/usecases/usecase.dart';
import 'package:clean_architecture_course/core/util/input_converter.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/enities/number_trivia.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia getConcreteNumberTrivia;
  late MockGetRandomNumberTrivia getRandomNumberTrivia;
  late MockInputConverter inputConverter;

  setUp(() {
    getConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    getRandomNumberTrivia = MockGetRandomNumberTrivia();
    inputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: getConcreteNumberTrivia,
      random: getRandomNumberTrivia,
      inputConverter: inputConverter,
    );
  });

  test(
    'initial should be Empty',
    () async {
      // assert
      expect(bloc.state, equals(Empty()));
    },
  );

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(inputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));

    void setUpMockGetConcreteNumberTriviaSuccess() =>
        when(getConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(inputConverter.stringToUnsignedInteger(any));
        // assert
        verify(inputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Error] when the input is invalid',
      build: () => bloc,
      setUp: () => when(inputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure())),
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => const <NumberTriviaState>[
        Error(message: INVALID_INPUT_FAILURE_MESSAGE)
      ],
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(getConcreteNumberTrivia(any));
        // assert
        verify(getConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'emits [Loading, Loaded] when data is gotten successfully',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () =>
          <NumberTriviaState>[Loading(), const Loaded(trivia: tNumberTrivia)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'emits [Loading, Error] with proper message for the error when when getting data fails',
      build: () => bloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(getConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(getRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(getRandomNumberTrivia(any));
        // assert
        verify(getRandomNumberTrivia(NoParams()));
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'emits [Loading, Loaded] when data is gotten successfully',
      build: () => bloc,
      setUp: () {
        when(getRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () =>
          <NumberTriviaState>[Loading(), const Loaded(trivia: tNumberTrivia)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'emits [Loading, Error] with proper message for the error when when getting data fails',
      build: () => bloc,
      setUp: () {
        when(getRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ],
    );
  });
}
