import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // mock
    if (event.email.isNotEmpty && event.password.isNotEmpty) {
      emit(AuthAuthenticated(event.email));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // mock
    
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const AuthUnauthenticated());
    } else if (event.password.length < 6) {
      emit(const AuthError("Password must be at least 6 characters long")); 
    } else {
      emit(AuthAuthenticated(event.email));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}
