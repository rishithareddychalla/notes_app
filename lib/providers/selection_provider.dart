import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final bool isSelectionMode;
  final Set<String> selectedNotes;

  SelectionState({this.isSelectionMode = false, this.selectedNotes = const {}});

  SelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedNotes,
  }) {
    return SelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedNotes: selectedNotes ?? this.selectedNotes,
    );
  }
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(SelectionState());

  void enableSelectionMode() {
    state = state.copyWith(isSelectionMode: true);
  }

  void disableSelectionMode() {
    state = state.copyWith(isSelectionMode: false, selectedNotes: {});
  }

  void toggleNoteSelection(String noteId) {
    final newSelectedNotes = Set<String>.from(state.selectedNotes);
    if (newSelectedNotes.contains(noteId)) {
      newSelectedNotes.remove(noteId);
    } else {
      newSelectedNotes.add(noteId);
    }
    state = state.copyWith(selectedNotes: newSelectedNotes);
  }

  void clearSelection() {
    state = state.copyWith(selectedNotes: {});
  }

  bool isSelected(String noteId) {
    return state.selectedNotes.contains(noteId);
  }
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
  return SelectionNotifier();
});