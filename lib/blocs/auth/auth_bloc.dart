import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'package:pusa_app/models/app_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckRequested>(_onCheckStatus);
  }

  Future<AppUser?> _fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final uid = userCredential.user!.uid;
      final profile = await _fetchUserProfile(uid);

      if (profile != null) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(const AuthError("Profile not found. Please contact support."));
      }
    } catch (_) {
      emit(const AuthError("Login failed. Please check your credentials."));
    }
  }

  Future<void> _onSignup(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final uid = userCredential.user!.uid;

      // Create document with serverTimestamp
      await _firestore.collection("users").doc(uid).set({
        "email": event.email,
        "introCompleted": false,
        "createdAt": FieldValue.serverTimestamp(),
        "catName": null,
      });

      // Re-fetch to convert timestamp properly
      final profile = await _fetchUserProfile(uid);

      if (profile != null) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(const AuthError("Signup succeeded but profile creation failed."));
      }
    } catch (_) {
      emit(const AuthError("Signup failed. Please try again."));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final profile = await _fetchUserProfile(user.uid);
        if (profile != null) {
          emit(AuthAuthenticated(profile));
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (_) {
        emit(const AuthError("Failed to load user profile."));
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
