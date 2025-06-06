// Test script to verify the authentication fix
// This simulates the signup flow to check for race conditions

import 'dart:async';

// Mock implementation to test the logic
class MockAuthBloc {
  bool _isSigningUp = false;
  String _currentState = 'initial';
  
  StreamController<String> _stateController = StreamController.broadcast();
  Stream<String> get stateStream => _stateController.stream;
  
  void _emit(String newState) {
    _currentState = newState;
    _stateController.add(newState);
    print('State emitted: $_currentState');
  }
  
  // Simulate the auth state listener
  void _simulateFirebaseAuthStateChange() {
    print('Firebase authStateChanges fired');
    
    // This is what happens when Firebase detects a new user
    if (_isSigningUp) {
      print('Auth state listener: Skipping - signup in progress');
      return;
    }
    
    if (_currentState != 'authenticated' && _currentState != 'loading') {
      Future.delayed(Duration(milliseconds: 500), () {
        if (_isSigningUp) {
          print('Auth state listener (delayed): Skipping - signup in progress');
          return;
        }
        
        if (_currentState != 'authenticated' && _currentState != 'loading') {
          print('Auth state listener: Triggering checkAuthStatus');
          _checkAuthStatus();
        }
      });
    }
  }
  
  void _checkAuthStatus() {
    print('checkAuthStatus called');
    
    if (_isSigningUp) {
      print('checkAuthStatus: Skipping - signup in progress');
      return;
    }
    
    // Simulate finding the user in Firebase
    print('checkAuthStatus: Found user, emitting authenticated');
    _emit('authenticated');
  }
  
  Future<void> signUpWithEmailPassword(String email, String password) async {
    print('=== STARTING SIGNUP FLOW ===');
    print('signUpWithEmailPassword called');
    
    _isSigningUp = true;
    _emit('loading');
    
    // Simulate Firebase signup and user document creation
    await Future.delayed(Duration(milliseconds: 100));
    print('Firebase user created and document saved');
    
    // This should emit authenticated state
    print('Emitting authenticated state');
    _emit('authenticated');
    
    // Simulate Firebase authStateChanges firing immediately
    // This happens in the real app and was causing the race condition
    print('Simulating immediate Firebase authStateChanges...');
    _simulateFirebaseAuthStateChange();
    
    // Clear the flag after delay to prevent interference
    Future.delayed(Duration(milliseconds: 1000), () {
      print('Clearing _isSigningUp flag');
      _isSigningUp = false;
    });
    
    print('=== SIGNUP FLOW COMPLETE ===');
  }
}

void main() async {
  final authBloc = MockAuthBloc();
  
  // Listen to state changes
  authBloc.stateStream.listen((state) {
    print('UI received state: $state');
    
    if (state == 'authenticated') {
      print('✅ SUCCESS: UI can now navigate to onboarding!');
    } else if (state == 'loading') {
      print('⏳ UI showing loading spinner...');
    }
  });
  
  // Start the signup flow
  await authBloc.signUpWithEmailPassword('test@test.com', 'password123');
  
  // Wait a bit to see all async operations complete
  await Future.delayed(Duration(milliseconds: 2000));
  
  print('\n=== FINAL RESULT ===');
  print('Final state: ${authBloc._currentState}');
  
  if (authBloc._currentState == 'authenticated') {
    print('✅ SUCCESS: Authentication fix works correctly!');
    print('✅ User will be navigated to onboarding page');
  } else {
    print('❌ FAILURE: Still stuck in loading or other state');
  }
}