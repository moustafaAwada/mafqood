import 'package:equatable/equatable.dart';

/// Response model for `GET /users/{userId}`.
/// Used in `UserProfileScreen` when tapping on a post author's profile picture
/// or navigating from chat.
class UserProfileModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool isFollowedByCurrentUser;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.isFollowedByCurrentUser,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isFollowedByCurrentUser:
          (json['isFollowedByCurrentUser'] as bool?) ?? false,
    );
  }

  UserProfileModel copyWith({
    bool? isFollowedByCurrentUser,
  }) {
    return UserProfileModel(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      isFollowedByCurrentUser:
          isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phoneNumber,
        profilePictureUrl,
        isFollowedByCurrentUser,
      ];
}
