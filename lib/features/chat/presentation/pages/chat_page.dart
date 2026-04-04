import 'package:flutter/material.dart';
import 'package:mafqood/features/chat/presentation/widgets/chat_item.dart';
import 'package:mafqood/features/chat/presentation/widgets/chat_search_bar.dart';
import 'package:mafqood/features/chat/presentation/widgets/empty_chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isSearching = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allChats = [
    {
      'name': 'مصطفى الألفي',
      'message': 'سلام عليكم، هل وجدت المفقود؟',
      'time': '9:25 AM',
      'unreadCount': 1,
      'initial': 'M',
      'isOnline': true,
    },
    {
      'name': 'مصطفى ناصر',
      'message': 'أنا عندي معلومة عنه، كلمني فضلاً',
      'time': '7:44 AM',
      'unreadCount': 3,
      'initial': 'N',
      'isOnline': false,
    },
    {
      'name': 'أحمد مصطفى',
      'message': 'سأدعمك في العثور عليه، شكراً لك',
      'time': 'أمس',
      'unreadCount': 0,
      'initial': 'A',
      'isOnline': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _allChats;
    return _allChats
        .where(
          (chat) =>
              chat['name'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              chat['message'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: ChatSearchBar(
          isSearching: _isSearching,
          searchQuery: _searchQuery,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onToggleSearch: () => setState(() => _isSearching = !_isSearching),
        ),
        body: _filteredChats.isEmpty
            ? EmptyChatState(searchQuery: _searchQuery)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: _filteredChats.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final chat = _filteredChats[index];
                  return ChatItem(
                    name: chat['name'] as String,
                    message: chat['message'] as String,
                    time: chat['time'] as String,
                    unreadCount: chat['unreadCount'] as int,
                    initial: chat['initial'] as String,
                    isOnline: chat['isOnline'] as bool,
                  );
                },
              ),
      ),
    );
  }
}
