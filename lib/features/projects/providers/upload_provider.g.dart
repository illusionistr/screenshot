// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedLanguageHash() => r'79c791200dfa955ab1055f0c718328c690107f18';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SelectedLanguage extends BuildlessAutoDisposeNotifier<String> {
  late final String projectId;

  String build(
    String projectId,
  );
}

/// See also [SelectedLanguage].
@ProviderFor(SelectedLanguage)
const selectedLanguageProvider = SelectedLanguageFamily();

/// See also [SelectedLanguage].
class SelectedLanguageFamily extends Family<String> {
  /// See also [SelectedLanguage].
  const SelectedLanguageFamily();

  /// See also [SelectedLanguage].
  SelectedLanguageProvider call(
    String projectId,
  ) {
    return SelectedLanguageProvider(
      projectId,
    );
  }

  @override
  SelectedLanguageProvider getProviderOverride(
    covariant SelectedLanguageProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedLanguageProvider';
}

/// See also [SelectedLanguage].
class SelectedLanguageProvider
    extends AutoDisposeNotifierProviderImpl<SelectedLanguage, String> {
  /// See also [SelectedLanguage].
  SelectedLanguageProvider(
    String projectId,
  ) : this._internal(
          () => SelectedLanguage()..projectId = projectId,
          from: selectedLanguageProvider,
          name: r'selectedLanguageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedLanguageHash,
          dependencies: SelectedLanguageFamily._dependencies,
          allTransitiveDependencies:
              SelectedLanguageFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  SelectedLanguageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  String runNotifierBuild(
    covariant SelectedLanguage notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(SelectedLanguage Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedLanguageProvider._internal(
        () => create()..projectId = projectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SelectedLanguage, String> createElement() {
    return _SelectedLanguageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedLanguageProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedLanguageRef on AutoDisposeNotifierProviderRef<String> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _SelectedLanguageProviderElement
    extends AutoDisposeNotifierProviderElement<SelectedLanguage, String>
    with SelectedLanguageRef {
  _SelectedLanguageProviderElement(super.provider);

  @override
  String get projectId => (origin as SelectedLanguageProvider).projectId;
}

String _$uploadProgressNotifierHash() =>
    r'ef8f6231049f8cfad466ba6eda17bb43ec65f307';

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
String _$projectScreenshotsHash() =>
    r'd9d78914254cbd553d35daada3d11c7ea930b07a';

abstract class _$ProjectScreenshots extends BuildlessAutoDisposeAsyncNotifier<
    Map<String, Map<String, List<ScreenshotModel>>>> {
  late final String projectId;

  FutureOr<Map<String, Map<String, List<ScreenshotModel>>>> build(
    String projectId,
  );
}

/// See also [ProjectScreenshots].
@ProviderFor(ProjectScreenshots)
const projectScreenshotsProvider = ProjectScreenshotsFamily();

/// See also [ProjectScreenshots].
class ProjectScreenshotsFamily extends Family<
    AsyncValue<Map<String, Map<String, List<ScreenshotModel>>>>> {
  /// See also [ProjectScreenshots].
  const ProjectScreenshotsFamily();

  /// See also [ProjectScreenshots].
  ProjectScreenshotsProvider call(
    String projectId,
  ) {
    return ProjectScreenshotsProvider(
      projectId,
    );
  }

  @override
  ProjectScreenshotsProvider getProviderOverride(
    covariant ProjectScreenshotsProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectScreenshotsProvider';
}

/// See also [ProjectScreenshots].
class ProjectScreenshotsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProjectScreenshots, Map<String, Map<String, List<ScreenshotModel>>>> {
  /// See also [ProjectScreenshots].
  ProjectScreenshotsProvider(
    String projectId,
  ) : this._internal(
          () => ProjectScreenshots()..projectId = projectId,
          from: projectScreenshotsProvider,
          name: r'projectScreenshotsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectScreenshotsHash,
          dependencies: ProjectScreenshotsFamily._dependencies,
          allTransitiveDependencies:
              ProjectScreenshotsFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectScreenshotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  FutureOr<Map<String, Map<String, List<ScreenshotModel>>>> runNotifierBuild(
    covariant ProjectScreenshots notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(ProjectScreenshots Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProjectScreenshotsProvider._internal(
        () => create()..projectId = projectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProjectScreenshots,
      Map<String, Map<String, List<ScreenshotModel>>>> createElement() {
    return _ProjectScreenshotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectScreenshotsProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectScreenshotsRef on AutoDisposeAsyncNotifierProviderRef<
    Map<String, Map<String, List<ScreenshotModel>>>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _ProjectScreenshotsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProjectScreenshots,
        Map<String, Map<String, List<ScreenshotModel>>>>
    with ProjectScreenshotsRef {
  _ProjectScreenshotsProviderElement(super.provider);

  @override
  String get projectId => (origin as ProjectScreenshotsProvider).projectId;
}

String _$uploadScreenshotsHash() => r'9d97cbe5b033cca1365d8d265bc040e6a78f3c9f';

/// See also [UploadScreenshots].
@ProviderFor(UploadScreenshots)
final uploadScreenshotsProvider =
    AutoDisposeNotifierProvider<UploadScreenshots, String>.internal(
  UploadScreenshots.new,
  name: r'uploadScreenshotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadScreenshotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UploadScreenshots = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
