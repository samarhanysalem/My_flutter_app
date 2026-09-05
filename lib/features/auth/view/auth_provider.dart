import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _authStateSubscription = _authRepository.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _authStateSubscription;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  AppUser? _user;
  AppUser? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _onAuthStateChanged(AppUser? user) {
    _user = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) {
    return _runAuthAction(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({required String email, required String password}) {
    return _runAuthAction(
      () => _authRepository.signUp(email: email, password: password),
    );
  }

  Future<void> signOut() => _authRepository.signOut();

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = _messageFor(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is AuthException) return error.message;
    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
