import 'package:cartasiapp/core/url.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<dynamic> login(String email, String password) async {
    try {
      FormData formData =
          FormData.fromMap({'email': email, 'password': password});
      Response response =
          await _dio.post('${Url.urlData}/login', data: formData);
      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? "Error: No response data";
    }
  }

  Future<List<Map<String, dynamic>>> userInfo(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/user-detail',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print("Response Data: ${response.data}"); // Debugging: Print response

      if (response.statusCode == 200) {
        // Ensure the response is correctly handled
        if (response.data is List) {
          return (response.data as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception('Response data is not a List');
        }
      } else {
        throw Exception(
            'Failed to load user info with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio errors or network errors
      if (e.response?.statusCode == 405) {
        // Specific handling for 405 errors
        throw Exception(
            'Method Not Allowed: Check the HTTP method and endpoint URL');
      }
      throw Exception('Failed to connect to server: ${e.message}');
    } catch (e) {
      // Handle JSON decoding or type errors
      throw Exception('Error processing user info: $e');
    }
  }

  Future<dynamic> dashboard(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/dashboard',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> listOfMember(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/list-members',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> listOfCategory() async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/list-category',
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> addMember(
    String firstName,
    String lastName,
    String address,
    String phone,
    String description,
    String birthDate,
    int categoryId,
    String hospital,
    String schoolName,
    String sdmsCode,
    String otherSupport,
    String token,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "first_name": firstName,
        "last_name": lastName,
        "address": address,
        "phone": phone,
        "description": description,
        "dob": birthDate,
        "cat_id": categoryId.toString(),
        "hospital": hospital,
        "school_name": schoolName,
        "sdms_code": sdmsCode,
        "other_support": otherSupport,
      });
      Response response = await _dio.post(
        '${Url.urlData}/create-member',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> addSupport(
    String reason,
    String amount,
    int memberId,
    String token,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "member_id": memberId,
        "reason": reason,
        "amount": amount,
      });
      Response response = await _dio.post(
        '${Url.urlData}/add-support',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> approveMember(
    int memberId,
    int status,
    String token,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "id": memberId,
        "status": status,
      });
      Response response = await _dio.post(
        '${Url.urlData}/approval',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> listOfUsers(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/list-user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> listOfSupports(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/list-support',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> listOfIncome(String token) async {
    try {
      Response response = await _dio.get(
        '${Url.urlData}/list-income',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }

  Future<dynamic> forgotPassword(String email) async {
    try {
      FormData formData = FormData.fromMap({
        "email": email,
      });
      Response response = await _dio.post(
        '${Url.urlData}/forget-password-api',
        data: formData,
      );

      // print(response);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    }
  }
}
