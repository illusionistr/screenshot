// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$uploadProgressNotifierHash() =>
    r'315efc41938839173b349412a6dd33577f244fa6';

/// See also [UploadProgressNotifier].
@ProviderFor(UploadProgressNotifier)
final uploadProgressNotifierProvider = AutoDisposeNotifierProvider<
    UploadProgressNotifier, Map<String, UploadProgress>>.internal(
  UploadProgressNotifier.new,
  name: r'uploadProgressNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadProgressNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UploadProgressNotifier
    = AutoDisposeNotifier<Map<String, UploadProgress>>;
String _$uploadQueueNotifierHash() =>
    r'736a47502ec03b829aef21d3a65b6e5f7736efd5';

/// See also [UploadQueueNotifier].
@ProviderFor(UploadQueueNotifier)
final uploadQueueNotifierProvider =
    AutoDisposeNotifierProvider<UploadQueueNotifier, List<UploadFile>>.internal(
  UploadQueueNotifier.new,
  name: r'uploadQueueNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadQueueNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UploadQueueNotifier = AutoDisposeNotifier<List<UploadFile>>;
String _$uploadCoordinatorHash() => r'c14bd440e63224ff711997746cac328f9172126b';

/// See also [UploadCoordinator].
@ProviderFor(UploadCoordinator)
final uploadCoordinatorProvider = AutoDisposeNotifierProvider<UploadCoordinator,
    AsyncValue<List<UploadResult>>>.internal(
  UploadCoordinator.new,
  name: r'uploadCoordinatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadCoordinatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UploadCoordinator
    = AutoDisposeNotifier<AsyncValue<List<UploadResult>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
