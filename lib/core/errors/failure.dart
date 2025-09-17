/// Custom failures for the application
// abstract class Failure {
//   const Failure(this.message);
//
//   final String message;
//
//   @override
//   String toString() => message;
// }
//
// /// Validation-related failures
// class ValidationFailure extends Failure {
//   const ValidationFailure(super.message);
// }
//
// /// Storage/persistence failures
// class StorageFailure extends Failure {
//   const StorageFailure(super.message);
// }
//
// /// Network/external service failures
// class NetworkFailure extends Failure {
//   const NetworkFailure(super.message);
// }
//
// /// Card scanning failures
// class ScanFailure extends Failure {
//   const ScanFailure(super.message);
// }
//
// /// Duplicate card failures
// class DuplicateCardFailure extends Failure {
//   const DuplicateCardFailure(super.message);
// }