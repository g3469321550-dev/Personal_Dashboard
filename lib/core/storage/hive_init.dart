import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

const _goalsBox = 'goals';
const _schedulesBox = 'schedules';
const _focusSessionsBox = 'focus_sessions';
const _focusCategoriesBox = 'focus_categories';
const _sleepRecordsBox = 'sleep_records';
const _exerciseRecordsBox = 'exercise_records';
const _aiCharactersBox = 'ai_characters';
const _chatMessagesBox = 'chat_messages';
const _rssSourcesBox = 'rss_sources';
const _rssArticlesBox = 'rss_articles';

Future<void> initHive() async {
  final dir = await getApplicationSupportDirectory();
  Hive.init(dir.path);
  await Future.wait([
    Hive.openBox(_goalsBox),
    Hive.openBox(_schedulesBox),
    Hive.openBox(_focusSessionsBox),
    Hive.openBox(_focusCategoriesBox),
    Hive.openBox(_sleepRecordsBox),
    Hive.openBox(_exerciseRecordsBox),
    Hive.openBox(_aiCharactersBox),
    Hive.openBox(_chatMessagesBox),
    Hive.openBox(_rssSourcesBox),
    Hive.openBox(_rssArticlesBox),
  ]);
}

Box get goalsBox => Hive.box(_goalsBox);
Box get schedulesBox => Hive.box(_schedulesBox);
Box get focusSessionsBox => Hive.box(_focusSessionsBox);
Box get focusCategoriesBox => Hive.box(_focusCategoriesBox);
Box get sleepRecordsBox => Hive.box(_sleepRecordsBox);
Box get exerciseRecordsBox => Hive.box(_exerciseRecordsBox);
Box get aiCharactersBox => Hive.box(_aiCharactersBox);
Box get chatMessagesBox => Hive.box(_chatMessagesBox);
Box get rssSourcesBox => Hive.box(_rssSourcesBox);
Box get rssArticlesBox => Hive.box(_rssArticlesBox);
