import 'package:mafqood/features/auth/domain/entities/user.dart';

class LoginResponsModel {
  final bool? isSuccess;
  final bool? hasData;
  User data;
  LoginResponsModel({
    required this.data,
    required this.hasData,
    required this.isSuccess,
  });
  factory LoginResponsModel.fomJson(Map<String, dynamic> json) {
    return LoginResponsModel(
      data: json['data'],
      hasData: json['hasData'],
      isSuccess: json['isSuccess'],
    );
  }
}
