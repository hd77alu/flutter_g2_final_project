import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/mentor_model.dart';
import '../services/firestore_service.dart';

abstract class MentorshipEvent {}

class LoadMentors extends MentorshipEvent {}

abstract class MentorshipState {}

class MentorshipInitial extends MentorshipState {}

class MentorshipLoading extends MentorshipState {}

class MentorshipLoaded extends MentorshipState {
  final List<Mentor> mentors;
  MentorshipLoaded(this.mentors);
}

class MentorshipError extends MentorshipState {}

class MentorshipBloc extends Bloc<MentorshipEvent, MentorshipState> {
  final FirestoreService firestoreService;

  MentorshipBloc(this.firestoreService) : super(MentorshipInitial()) {
    on<LoadMentors>((event, emit) async {
      emit(MentorshipLoading());

      try {
        final mentors = await firestoreService.getMentors();
        emit(MentorshipLoaded(mentors));
      } catch (e) {
        emit(MentorshipError());
      }
    });
  }
}