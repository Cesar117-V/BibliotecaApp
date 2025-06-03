import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your XAMPP server's IP address if testing on a physical device,
  // or '10.0.2.2' for Android emulator to access host machine localhost.
  // For iOS simulator, 'localhost' or '127.0.0.1' usually works.
  static const String _baseUrl = 'http://192.168.1.70/biblioteca_api'; // For Android Emulator

  // If you are testing on a physical Android device and your XAMPP is on your computer:
  // static const String _baseUrl = 'http://YOUR_COMPUTER_IP_ADDRESS/biblioteca_api';
  // (e.g., 'http://192.168.1.100/biblioteca_api')

  // Common function for making GET requests
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Common function for making POST requests
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Common function for making PUT requests (for updates)
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Common function for making DELETE requests
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Handles the HTTP response, checks status, and decodes JSON
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successful response
      return jsonDecode(response.body);
    } else {
      // Server responded with an error status code
      String errorMessage = 'Error: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody.containsKey('message')) {
          errorMessage = errorBody['message'];
        }
      } catch (e) {
        // If the response body is not JSON or not as expected
        errorMessage = 'Server error with status ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMessage);
    }
  }

  // --- Specific API Calls based on your DB Schema ---

  // User Endpoints
  Future<List<dynamic>> getUsers() async {
    final response = await get('get_users.php');
    if (response['success'] && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to load users: ${response['message']}');
  }

  Future<Map<String, dynamic>> addUser(Map<String, dynamic> userData) async {
    return await post('add_user.php', userData);
  }

  // Example: Login (assuming you'll have a login endpoint)
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final response = await post('login.php', {'correo': correo, 'contrasena': contrasena});
    return response; // Handle success/failure based on the backend response
  }

  // Book Endpoints
  Future<List<dynamic>> getBooks() async {
    final response = await get('get_books.php');
    if (response['success'] && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to load books: ${response['message']}');
  }

  Future<Map<String, dynamic>> addBook(Map<String, dynamic> bookData) async {
    return await post('add_book.php', bookData);
  }

  // Loan Endpoints
  Future<List<dynamic>> getLoans() async {
    final response = await get('get_loans.php');
    if (response['success'] && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to load loans: ${response['message']}');
  }

  Future<Map<String, dynamic>> addLoan(Map<String, dynamic> loanData) async {
    return await post('add_loan.php', loanData);
  }

  // You would continue to add methods for all your tables and operations:
  // getCategories, addCategory, getAuthors, addAuthor, getCareers, addCareer,
  // getReturns, addReturn, updateBook, deleteBook, etc.
}