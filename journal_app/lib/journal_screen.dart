import 'package:flutter/material.dart';
import 'package:journal_app/entry_list.dart';
import 'package:journal_app/journal_card.dart';
import 'package:journal_app/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await loadEntries();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Journal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: journalEntries.isEmpty
          ? const Center(
              child: Text(
                'No entries yet. Tap + to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: journalEntries.length,
              itemBuilder: (context, index) {
                final reversedIndex = journalEntries.length - 1 - index;
                return JournalCard(entry: journalEntries[reversedIndex]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: JournalEntry(
                    onSave: (entry) {
                      // Trigger a rebuild when a new entry is added to update the list
                      setState(() {
                        journalEntries.add(entry);
                        saveEntries(); // Persist the new entry list to local storage
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.edit_document),
      ),
    );
  }
}
