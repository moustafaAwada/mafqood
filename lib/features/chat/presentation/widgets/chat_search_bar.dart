import 'package:flutter/material.dart';

class ChatSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;

  const ChatSearchBar({
    super.key,
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggleSearch,
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(ChatSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      elevation: 0,
      centerTitle: true,
      title: widget.isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: colorScheme.onPrimary),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'البحث في الدردشات...',
                hintStyle: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.7),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              onChanged: widget.onSearchChanged,
            )
          : Text(
              'الدردشات',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            widget.isSearching ? Icons.close : Icons.search,
            color: colorScheme.onPrimary,
          ),
          onPressed: () {
            widget.onToggleSearch();
            if (widget.isSearching) {
              _searchController.clear();
              widget.onSearchChanged('');
            }
          },
        ),
      ],
    );
  }
}
