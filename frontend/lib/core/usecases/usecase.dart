/// Base UseCase interface
/// Each use case has a single method [call] with params [P] and returns [R]
abstract class UseCase<R, P> {
  Future<R> call(P params);
}

/// NoParams class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
