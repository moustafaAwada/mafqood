import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/account/domain/usecases/update_user_profile_use_case.dart';
import 'package:mafqood/features/account/presentation/cubit/account_cubit.dart';
import 'package:mafqood/features/account/presentation/cubit/account_state.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:dartz/dartz.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late AccountRepository repo;
  late AccountCubit cubit;

  setUpAll(() {
    registerFallbackValue(UpdateProfileParams());
  });

  setUp(() {
    repo = _MockAccountRepository();
    cubit = AccountCubit(
      accountRepository: repo,
      updateUserProfileUseCase: UpdateUserProfileUseCase(repo),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<AccountCubit, AccountState>(
    'emits failure when phone is invalid',
    build: () => cubit,
    act: (c) => c.updateProfile(UpdateProfileParams(
      firstName: 'Ahmed',
      lastName: 'Mohamed',
      phoneNumber: '01234',
    )),
    expect: () => [
      isA<UpdateProfileFailure>(),
    ],
    verify: (_) {
      verifyNever(() => repo.updateUserProfile(any()));
    },
  );

  blocTest<AccountCubit, AccountState>(
    'emits failure when image extension is invalid',
    build: () => cubit,
    act: (c) => c.updateProfile(UpdateProfileParams(
      profileImage: File('D:/tmp/not_an_image.txt'),
    )),
    expect: () => [
      isA<UpdateProfileFailure>(),
    ],
    verify: (_) {
      verifyNever(() => repo.updateUserProfile(any()));
    },
  );

  blocTest<AccountCubit, AccountState>(
    'calls repository when valid info update (name+phone)',
    build: () {
      when(() => repo.updateUserProfile(any())).thenAnswer(
        (_) async => Right(
          UserProfileEntity(
            id: 'u1',
            email: 'a@b.com',
            name: 'Ahmed Mohamed',
            phoneNumber: '01012345678',
            profilePictureUrl: null,
            isFollowedByCurrentUser: false,
          ),
        ),
      );
      return cubit;
    },
    act: (c) => c.updateProfile(UpdateProfileParams(
      firstName: 'Ahmed',
      lastName: 'Mohamed',
      phoneNumber: '01012345678',
    )),
    expect: () => [
      isA<UpdateProfileLoading>(),
      isA<UpdateProfileSuccess>(),
    ],
    verify: (_) {
      verify(() => repo.updateUserProfile(any())).called(1);
    },
  );
}

