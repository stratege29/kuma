import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Simple script to upload sample stories to Firestore
// Run with: dart upload_stories.dart

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "your-api-key", // Replace with your API key
      appId: "1:116620596804:ios:59c3ec0d9c5b8a7ad27b81", // Replace with your app ID
      messagingSenderId: "116620596804",
      projectId: "kumafire-7864b",
    ),
  );

  final firestore = FirebaseFirestore.instance;

  // Read sample stories
  final file = File('sample-stories.json');
  if (!file.existsSync()) {
    print('Error: sample-stories.json not found');
    print('Make sure the file exists in the same directory as this script');
    return;
  }

  try {
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString);
    final stories = data['stories'] as List;

    print('Uploading ${stories.length} stories to Firestore...');

    // Upload each story
    for (int i = 0; i < stories.length; i++) {
      final story = stories[i] as Map<String, dynamic>;
      final storyId = story['id'] as String;

      print('Uploading story ${i + 1}/${stories.length}: $storyId');

      await firestore.collection('stories').doc(storyId).set(story);
    }

    print('✅ Successfully uploaded all stories to Firestore!');
    print('');
    print('Your stories are now available in Firebase Console:');
    print('https://console.firebase.google.com/project/kumafire-7864b/firestore');
    
  } catch (e) {
    print('❌ Error uploading stories: $e');
  }
}