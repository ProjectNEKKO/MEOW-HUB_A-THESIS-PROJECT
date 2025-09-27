import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckRequested>(_onCheckStatus);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userCredential.user!.uid));
    } catch (_) {
      emit(const AuthError("Login failed. Please check your credentials."));
    }
  }

  Future<void> _onSignup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userCredential.user!.uid));
    } catch (_) {
      emit(const AuthError("Signup failed. Please try again."));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user.uid));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
