part of 'admission_bloc.dart';

abstract class AdmissionEvent {}

class MarkAsCompleteClicked extends AdmissionEvent {
  final bool isComplete;

  // Constructor takes a bool to specify the desired status (true or false)
  MarkAsCompleteClicked(this.isComplete);
}

// New event class that includes isResult and isPassed
class MarkAsResultPassedClicked extends AdmissionEvent {
  final bool isResult;
  final bool isPassed;
  final bool isComplete;

  // Constructor takes both isResult and isPassed as bool values
  MarkAsResultPassedClicked({
    required this.isResult,  // Whether the result is available (true or false)
    required this.isPassed,  // Whether the person has passed (true or false)
    required this.isComplete,
  });
}