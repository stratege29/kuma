# Firestore Database Structure for Kuma Stories

## Collection: `stories`

Each document in the `stories` collection should have the following structure:

```json
{
  "id": "story_senegal_001",
  "title": "Le Lion et la Souris",
  "country": "Sénégal",
  "countryCode": "SN",
  "content": {
    "fr": "Il était une fois, dans la savane du Sénégal, un lion majestueux...",
    "en": "Once upon a time, in the Senegalese savanna, a majestic lion...",
    "wo": "Benn bés, ci àll bi ci Senegaal, gaynde gu mag..."
  },
  "imageUrl": "https://storage.googleapis.com/kuma-stories/senegal/lion-mouse.jpg",
  "audioUrl": "https://storage.googleapis.com/kuma-stories/senegal/lion-mouse-fr.mp3",
  "estimatedReadingTime": 5,
  "estimatedAudioDuration": 8,
  "values": ["Entraide", "Respect", "Gratitude"],
  "quizQuestions": [
    {
      "id": "q1",
      "question": "Pourquoi le lion a-t-il épargné la souris?",
      "options": [
        "Parce qu'il n'avait pas faim",
        "Parce que la souris l'a fait rire",
        "Parce qu'il était fatigué",
        "Parce que la souris était trop petite"
      ],
      "correctAnswer": 1,
      "explanation": "Le lion a trouvé la souris amusante et a décidé de la laisser partir."
    },
    {
      "id": "q2",
      "question": "Comment la souris a-t-elle aidé le lion?",
      "options": [
        "En lui apportant de la nourriture",
        "En rongeant les cordes du piège",
        "En appelant d'autres animaux",
        "En lui donnant de l'eau"
      ],
      "correctAnswer": 1,
      "explanation": "La souris a utilisé ses petites dents pour ronger les cordes qui emprisonnaient le lion."
    }
  ],
  "metadata": {
    "author": "Tradition orale sénégalaise",
    "origin": "Sénégal",
    "moralLesson": "Aucun service n'est trop petit; l'entraide n'a pas de taille",
    "keywords": ["entraide", "gratitude", "animaux", "savane", "amitié"],
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

## Key Fields Explanation:

### Required Fields:
- **id**: Unique identifier (e.g., `story_countrycode_number`)
- **title**: Story title
- **country**: Full country name in French
- **countryCode**: ISO 3166-1 alpha-2 code (e.g., "SN" for Senegal)
- **content**: Multilingual content object with language codes as keys
- **imageUrl**: URL to story cover image (Firebase Storage)
- **audioUrl**: URL to audio narration (Firebase Storage)
- **estimatedReadingTime**: Reading time in minutes
- **estimatedAudioDuration**: Audio duration in minutes
- **values**: Array of moral values taught by the story
- **quizQuestions**: Array of quiz questions (see structure below)
- **metadata**: Story metadata object

### Optional Fields:
- **tags**: Array of searchable tags
- **isPublished**: Boolean to control story visibility
- **order**: Number for sorting stories within a country

## Quiz Question Structure:
```json
{
  "id": "unique_question_id",
  "question": "Question text",
  "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
  "correctAnswer": 0, // Index of correct option (0-based)
  "explanation": "Optional explanation shown after answering"
}
```

## Firestore Indexes Needed:

1. **Composite Index**: `country` (ASC) + `order` (ASC)
2. **Composite Index**: `country` (ASC) + `isPublished` (ASC)
3. **Array Contains**: `tags`
4. **Single Field**: `isPublished`

## Firebase Storage Structure:

```
/stories
  /senegal
    /images
      - lion-mouse.jpg
      - crocodile-hunter.jpg
    /audio
      /fr
        - lion-mouse.mp3
        - crocodile-hunter.mp3
      /en
        - lion-mouse.mp3
      /wo
        - lion-mouse.mp3
  /mali
    /images
    /audio
```

## Sample Queries:

```dart
// Get all stories for a country
firestore
  .collection('stories')
  .where('country', isEqualTo: 'Sénégal')
  .where('isPublished', isEqualTo: true)
  .orderBy('order')
  .get();

// Get stories by difficulty
firestore
  .collection('stories')
  .where('metadata.difficulty', isEqualTo: 'facile')
  .get();

// Search stories by tags
firestore
  .collection('stories')
  .where('tags', arrayContains: 'animaux')
  .get();
```

## Migration Notes:

1. The existing Story model's `isCompleted` and `isUnlocked` fields should NOT be stored in Firestore
2. These are user-specific states that belong in the user's document
3. Store them in: `users/{userId}/progress/completedStories` and `unlockedCountries`

## Security Rules for Stories:

```javascript
match /stories/{storyId} {
  // Anyone can read published stories if authenticated
  allow read: if request.auth != null && resource.data.isPublished == true;
  
  // Only admins can write
  allow write: if request.auth != null && 
    request.auth.token.admin == true;
}
```