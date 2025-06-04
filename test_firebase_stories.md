# Test Firebase Stories Integration

## To add sample stories to Firestore manually:

### Option 1: Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/project/kumafire-7864b/firestore)
2. Click "Start collection"
3. Collection ID: `stories`
4. Add these sample documents:

#### Document 1: `story_sn_001`
```json
{
  "id": "story_sn_001",
  "title": "Le Lion et la Souris",
  "country": "Sénégal",
  "countryCode": "SN",
  "content": {
    "fr": "Il était une fois, dans la vaste savane du Sénégal, un lion majestueux qui dormait paisiblement sous un baobab..."
  },
  "imageUrl": "https://via.placeholder.com/400x300",
  "audioUrl": "",
  "estimatedReadingTime": 5,
  "estimatedAudioDuration": 7,
  "values": ["Entraide", "Gratitude", "Humilité"],
  "quizQuestions": [
    {
      "id": "q1",
      "question": "Pourquoi le lion a-t-il épargné la souris?",
      "options": ["Il n'avait pas faim", "Il était amusé par son audace", "Il avait peur", "Il était fatigué"],
      "correctAnswer": 1,
      "explanation": "Le lion a trouvé amusante l'idée qu'une si petite créature puisse un jour l'aider."
    }
  ],
  "metadata": {
    "author": "Tradition orale sénégalaise",
    "origin": "Sénégal",
    "moralLesson": "L'entraide n'a pas de taille",
    "keywords": ["entraide", "gratitude", "animaux"],
    "ageGroup": "5-12",
    "difficulty": "facile",
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-15T10:00:00Z"
  },
  "tags": ["animaux", "morale", "classique"],
  "isPublished": true,
  "order": 1
}
```

#### Document 2: `story_ml_001`
```json
{
  "id": "story_ml_001",
  "title": "Soundiata Keïta",
  "country": "Mali",
  "countryCode": "ML",
  "content": {
    "fr": "Dans l'ancien royaume du Mandé, naquit un enfant extraordinaire nommé Soundiata..."
  },
  "imageUrl": "https://via.placeholder.com/400x300",
  "audioUrl": "",
  "estimatedReadingTime": 8,
  "estimatedAudioDuration": 10,
  "values": ["Persévérance", "Courage", "Justice"],
  "quizQuestions": [
    {
      "id": "q1",
      "question": "Quel était le handicap de Soundiata?",
      "options": ["Il était aveugle", "Il ne pouvait pas parler", "Il ne pouvait pas marcher", "Il était sourd"],
      "correctAnswer": 2,
      "explanation": "Soundiata ne pouvait pas marcher jusqu'à l'âge de sept ans."
    }
  ],
  "metadata": {
    "author": "Épopée mandingue",
    "origin": "Mali",
    "moralLesson": "Les plus grandes forces naissent des plus grandes épreuves",
    "keywords": ["histoire", "empire", "courage"],
    "ageGroup": "8-15",
    "difficulty": "moyen",
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-15T10:00:00Z"
  },
  "tags": ["histoire", "héros", "empire"],
  "isPublished": true,
  "order": 1
}
```

### Option 2: Using Firebase CLI (Advanced)

If you have Firebase CLI installed:

```bash
firebase firestore:delete --all-collections --project kumafire-7864b
# Then import data
```

## After adding stories:

1. Restart the app
2. Check the debug console for:
   - "StoryRemoteDataSource: Found X stories"
   - "HomeBloc: Successfully loaded X stories from Firestore"

## Troubleshooting:

- If you see "No stories found", check that `isPublished: true` is set
- If you see index errors, the queries have been simplified to avoid composite indexes
- Stories will be sorted locally by country and order

## Quick Test:

Add just one simple story first:

Document ID: `test_story`
```json
{
  "id": "test_story",
  "title": "Test Story",
  "country": "Sénégal",
  "countryCode": "SN",
  "content": {"fr": "Une histoire de test"},
  "imageUrl": "",
  "audioUrl": "",
  "estimatedReadingTime": 1,
  "estimatedAudioDuration": 1,
  "values": ["Test"],
  "quizQuestions": [],
  "metadata": {
    "author": "Test",
    "origin": "Test",
    "moralLesson": "Test",
    "keywords": ["test"],
    "ageGroup": "5-12",
    "difficulty": "facile"
  },
  "tags": ["test"],
  "isPublished": true,
  "order": 1
}
```

If this works, you'll see it in the app and can add more complex stories.