import 'package:kuma/core/constants/countries.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class MockDataService {
  static List<Story> generateMockStories() {
    final stories = <Story>[];
    
    for (int i = 0; i < Countries.TEST_COUNTRIES.length; i++) {
      final country = Countries.TEST_COUNTRIES[i];
      
      // Générer 2 histoires par pays
      for (int j = 1; j <= 2; j++) {
        stories.add(_createStory(country, j, i == 0 && j == 1)); // Première histoire du Sénégal débloquée
      }
    }
    
    return stories;
  }

  static Story _createStory(String country, int storyNumber, bool isUnlocked) {
    final countryCode = Countries.COUNTRY_ORDER[country] ?? '';
    final storyId = '${countryCode.toLowerCase()}_$storyNumber';
    
    return Story(
      id: storyId,
      title: _getStoryTitle(country, storyNumber),
      country: country,
      countryCode: countryCode,
      content: {'fr': _getStoryContent(country, storyNumber)},
      imageUrl: 'placeholder_${countryCode.toLowerCase()}_$storyNumber.jpg',
      audioUrl: 'placeholder_${countryCode.toLowerCase()}_$storyNumber.mp3',
      estimatedReadingTime: 3 + (storyNumber % 3),
      estimatedAudioDuration: 4 + (storyNumber % 3),
      values: _getStoryValues(country, storyNumber),
      quizQuestions: _generateQuizQuestions(country, storyNumber),
      metadata: StoryMetadata(
        author: 'Conte traditionnel ${country.toLowerCase()}',
        origin: country,
        moralLesson: _getMoralLesson(country, storyNumber),
        keywords: _getKeywords(country, storyNumber),
        ageGroup: '6-12 ans',
        difficulty: storyNumber == 1 ? 'Facile' : 'Moyen',
        createdAt: DateTime.now().subtract(Duration(days: storyNumber * 10)),
        updatedAt: DateTime.now().subtract(Duration(days: storyNumber * 5)),
      ),
      isUnlocked: isUnlocked,
      isCompleted: false,
    );
  }

  static String _getStoryTitle(String country, int storyNumber) {
    final titles = <String, List<String>>{
      'Senegal': [
        'Leuk le lièvre et Bouki l\'hyène',
        'La sagesse de la grand-mère Coumba'
      ],
      'Cote d\'Ivoire': [
        'Anansi et la sagesse du monde',
        'Le tambour magique de Yamoussoukro'
      ],
      'Ghana': [
        'Le tambour magique d\'Akan',
        'Kweku Anansi et les histoires du monde'
      ],
      'Nigeria': [
        'La tortue et l\'aigle royal',
        'Les fils du roi et le secret du baobab'
      ],
      'Cameroon': [
        'Le chasseur et l\'esprit de la forêt',
        'La princesse et le caméléon magique'
      ],
      'Kenya': [
        'Le lion et le petit oiseau',
        'La légende du mont Kenya'
      ],
      'Ethiopia': [
        'La reine de Saba et la sagesse',
        'Le berger et l\'étoile filante'
      ],
      'Egypt': [
        'Le pharaon et le scribe loyal',
        'Le secret des pyramides'
      ],
      'Morocco': [
        'Le marchand et les trois souhaits',
        'La rose du désert'
      ],
      'South Africa': [
        'L\'antilope et le crocodile',
        'Ubuntu : nous sommes car nous sommes'
      ],
    };
    
    return titles[country]?[storyNumber - 1] ?? 'Conte de $country $storyNumber';
  }

  static String _getStoryContent(String country, int storyNumber) {
    if (country == 'Senegal' && storyNumber == 1) {
      return '''Il était une fois, dans la savane sénégalaise, deux amis très différents : Leuk le lièvre, petit mais très malin, et Bouki l'hyène, grosse et forte mais pas très intelligente.

Un jour, les deux amis décidèrent de creuser un puits ensemble car la saison sèche approchait et l'eau se faisait rare. Ils travaillèrent dur sous le soleil brûlant, Bouki creusant avec sa force et Leuk l'encourageant avec ses mots.

Quand le puits fut terminé et qu'il était rempli d'eau fraîche et claire, Leuk eut une idée. "Mon ami Bouki, dit-il, nous devrions surveiller notre puits à tour de rôle pour que personne ne vienne voler notre eau."

Bouki, fatiguée par le travail, accepta immédiatement. "Bonne idée, Leuk ! Tu surveilleras la nuit et moi le jour."

Mais le lièvre malin avait un autre plan. Chaque nuit, au lieu de surveiller, il buvait l'eau du puits et se roulait dans la boue pour cacher les preuves. Le matin, quand Bouki arrivait, le niveau de l'eau avait baissé.

"Quelqu'un vient boire notre eau la nuit !" se plaignait Bouki.

"C'est terrible ! répondait Leuk avec un air innocent. Il faut attraper ce voleur !"

Cette histoire nous enseigne que l'intelligence peut triompher de la force, mais qu'il ne faut jamais trahir la confiance de ses amis. La ruse de Leuk lui a permis d'obtenir ce qu'il voulait, mais au prix de son amitié avec Bouki.

Dans nos traditions africaines, nous valorisons la sagesse et l'entraide. Cette histoire nous rappelle l'importance de rester honnête avec ceux qui nous font confiance.''';
    }
    
    return '''Il était une fois, dans le magnifique pays de $country, une histoire extraordinaire qui se transmettait de génération en génération.

Cette histoire, la numéro $storyNumber de notre collection, raconte la sagesse de nos ancêtres et les valeurs importantes de notre culture africaine. Les personnages de ce conte nous enseignent des leçons précieuses sur la vie.

À travers les aventures captivantes de nos héros, nous découvrons l'importance du respect, de la solidarité et de la persévérance. Ces valeurs sont au cœur de la tradition orale africaine qui unit tous les peuples du continent.

Le conte se déroule dans un village paisible où la communauté vit en harmonie avec la nature. Les anciens transmettent leur sagesse aux plus jeunes à travers ces récits merveilleux qui traversent les siècles.

Cette histoire nous rappelle que chaque défi peut être surmonté avec de la créativité et de la détermination. Les héros de nos contes africains nous inspirent à être courageux face aux difficultés et généreux envers notre prochain.

La tradition orale de $country est riche en enseignements. Chaque conte porte en lui la mémoire collective et les valeurs fondamentales qui guident notre société vers l'harmonie et la prospérité.

Que cette histoire vous inspire et vous rappelle la beauté de notre héritage africain commun.''';
  }

  static List<String> _getStoryValues(String country, int storyNumber) {
    final allValues = [
      'Courage', 'Sagesse', 'Générosité', 'Respect', 'Solidarité',
      'Persévérance', 'Honnêteté', 'Humilité', 'Patience', 'Bienveillance'
    ];
    
    final startIndex = (country.hashCode + storyNumber) % allValues.length;
    return [
      allValues[startIndex % allValues.length],
      allValues[(startIndex + 1) % allValues.length],
      if (storyNumber == 2) allValues[(startIndex + 2) % allValues.length],
    ];
  }

  static String _getMoralLesson(String country, int storyNumber) {
    final lessons = [
      'La sagesse triomphe de la force',
      'L\'union fait la force',
      'La patience mène à la réussite',
      'L\'honnêteté est la plus belle des vertus',
      'Le respect des anciens apporte la bénédiction',
      'La générosité est récompensée',
      'L\'humilité ouvre toutes les portes',
      'La persévérance vainc tous les obstacles',
    ];
    
    return lessons[(country.hashCode + storyNumber) % lessons.length];
  }

  static List<String> _getKeywords(String country, int storyNumber) {
    final baseKeywords = ['tradition', 'sagesse', 'culture'];
    final specificKeywords = {
      'Senegal': ['lièvre', 'hyène', 'teranga'],
      'Cote d\'Ivoire': ['anansi', 'araignée', 'palabre'],
      'Ghana': ['akan', 'tambour', 'adinkra'],
      'Nigeria': ['tortue', 'aigle', 'igbo'],
      'Cameroon': ['forêt', 'chasseur', 'bamiléké'],
      'Kenya': ['lion', 'savane', 'masaï'],
      'Ethiopia': ['reine', 'saba', 'highlands'],
      'Egypt': ['pharaon', 'nil', 'pyramide'],
      'Morocco': ['désert', 'rose', 'berbère'],
      'South Africa': ['ubuntu', 'antilope', 'zulu'],
    };
    
    return [...baseKeywords, ...specificKeywords[country] ?? ['conte', 'africain']];
  }

  static List<QuizQuestion> _generateQuizQuestions(String country, int storyNumber) {
    return [
      QuizQuestion(
        id: '${country.toLowerCase()}_${storyNumber}_q1',
        question: 'Dans quel pays se déroule cette histoire ?',
        options: [
          'Ghana',
          country,
          'Nigeria',
          'Kenya'
        ]..shuffle(),
        correctAnswer: 1, // Toujours placer la bonne réponse en position 1
        explanation: 'Cette histoire fait partie du riche patrimoine oral de $country.',
      ),
      QuizQuestion(
        id: '${country.toLowerCase()}_${storyNumber}_q2',
        question: 'Quelle est la principale valeur transmise par ce conte ?',
        options: [
          'La richesse',
          _getStoryValues(country, storyNumber).first,
          'La célébrité',
          'La paresse'
        ],
        correctAnswer: 1,
        explanation: 'Les contes africains transmettent des valeurs importantes pour la vie en société.',
      ),
      QuizQuestion(
        id: '${country.toLowerCase()}_${storyNumber}_q3',
        question: 'Pourquoi les contes africains sont-ils importants ?',
        options: [
          'Ils divertissent seulement',
          'Ils transmettent la sagesse des ancêtres',
          'Ils font peur aux enfants',
          'Ils n\'ont pas d\'importance'
        ],
        correctAnswer: 1,
        explanation: 'La tradition orale africaine préserve la mémoire collective et transmet les valeurs fondamentales.',
      ),
    ];
  }
}