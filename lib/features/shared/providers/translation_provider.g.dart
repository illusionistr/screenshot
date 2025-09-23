// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$translationStateHash() => r'3579c8ccb4305c71cbe068d6e402012419caaf51';

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

/// Helper providers for easy access
///
/// Copied from [translationState].
@ProviderFor(translationState)
const translationStateProvider = TranslationStateFamily();

/// Helper providers for easy access
///
/// Copied from [translationState].
class TranslationStateFamily extends Family<TranslationState> {
  /// Helper providers for easy access
  ///
  /// Copied from [translationState].
  const TranslationStateFamily();

  /// Helper providers for easy access
  ///
  /// Copied from [translationState].
  TranslationStateProvider call(
    String projectId,
  ) {
    return TranslationStateProvider(
      projectId,
    );
  }

  @override
  TranslationStateProvider getProviderOverride(
    covariant TranslationStateProvider provider,
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
  String? get name => r'translationStateProvider';
}

/// Helper providers for easy access
///
/// Copied from [translationState].
class TranslationStateProvider extends AutoDisposeProvider<TranslationState> {
  /// Helper providers for easy access
  ///
  /// Copied from [translationState].
  TranslationStateProvider(
    String projectId,
  ) : this._internal(
          (ref) => translationState(
            ref as TranslationStateRef,
            projectId,
          ),
          from: translationStateProvider,
          name: r'translationStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$translationStateHash,
          dependencies: TranslationStateFamily._dependencies,
          allTransitiveDependencies:
              TranslationStateFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  TranslationStateProvider._internal(
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
  Override overrideWith(
    TranslationState Function(TranslationStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TranslationStateProvider._internal(
        (ref) => create(ref as TranslationStateRef),
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
  AutoDisposeProviderElement<TranslationState> createElement() {
    return _TranslationStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TranslationStateProvider && other.projectId == projectId;
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
mixin TranslationStateRef on AutoDisposeProviderRef<TranslationState> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _TranslationStateProviderElement
    extends AutoDisposeProviderElement<TranslationState>
    with TranslationStateRef {
  _TranslationStateProviderElement(super.provider);

  @override
  String get projectId => (origin as TranslationStateProvider).projectId;
}

String _$hasActiveTranslationsHash() =>
    r'26f5c673d4c1cc11f8063517e6604dc324874a3a';

/// See also [hasActiveTranslations].
@ProviderFor(hasActiveTranslations)
const hasActiveTranslationsProvider = HasActiveTranslationsFamily();

/// See also [hasActiveTranslations].
class HasActiveTranslationsFamily extends Family<bool> {
  /// See also [hasActiveTranslations].
  const HasActiveTranslationsFamily();

  /// See also [hasActiveTranslations].
  HasActiveTranslationsProvider call(
    String projectId,
  ) {
    return HasActiveTranslationsProvider(
      projectId,
    );
  }

  @override
  HasActiveTranslationsProvider getProviderOverride(
    covariant HasActiveTranslationsProvider provider,
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
  String? get name => r'hasActiveTranslationsProvider';
}

/// See also [hasActiveTranslations].
class HasActiveTranslationsProvider extends AutoDisposeProvider<bool> {
  /// See also [hasActiveTranslations].
  HasActiveTranslationsProvider(
    String projectId,
  ) : this._internal(
          (ref) => hasActiveTranslations(
            ref as HasActiveTranslationsRef,
            projectId,
          ),
          from: hasActiveTranslationsProvider,
          name: r'hasActiveTranslationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasActiveTranslationsHash,
          dependencies: HasActiveTranslationsFamily._dependencies,
          allTransitiveDependencies:
              HasActiveTranslationsFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  HasActiveTranslationsProvider._internal(
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
  Override overrideWith(
    bool Function(HasActiveTranslationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasActiveTranslationsProvider._internal(
        (ref) => create(ref as HasActiveTranslationsRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _HasActiveTranslationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasActiveTranslationsProvider &&
        other.projectId == projectId;
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
mixin HasActiveTranslationsRef on AutoDisposeProviderRef<bool> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _HasActiveTranslationsProviderElement
    extends AutoDisposeProviderElement<bool> with HasActiveTranslationsRef {
  _HasActiveTranslationsProviderElement(super.provider);

  @override
  String get projectId => (origin as HasActiveTranslationsProvider).projectId;
}

String _$translationProgressHash() =>
    r'0dac645d89565ee1746fd9e22641ab5448cb8adf';

/// See also [translationProgress].
@ProviderFor(translationProgress)
const translationProgressProvider = TranslationProgressFamily();

/// See also [translationProgress].
class TranslationProgressFamily extends Family<double> {
  /// See also [translationProgress].
  const TranslationProgressFamily();

  /// See also [translationProgress].
  TranslationProgressProvider call(
    String projectId,
  ) {
    return TranslationProgressProvider(
      projectId,
    );
  }

  @override
  TranslationProgressProvider getProviderOverride(
    covariant TranslationProgressProvider provider,
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
  String? get name => r'translationProgressProvider';
}

/// See also [translationProgress].
class TranslationProgressProvider extends AutoDisposeProvider<double> {
  /// See also [translationProgress].
  TranslationProgressProvider(
    String projectId,
  ) : this._internal(
          (ref) => translationProgress(
            ref as TranslationProgressRef,
            projectId,
          ),
          from: translationProgressProvider,
          name: r'translationProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$translationProgressHash,
          dependencies: TranslationProgressFamily._dependencies,
          allTransitiveDependencies:
              TranslationProgressFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  TranslationProgressProvider._internal(
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
  Override overrideWith(
    double Function(TranslationProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TranslationProgressProvider._internal(
        (ref) => create(ref as TranslationProgressRef),
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
  AutoDisposeProviderElement<double> createElement() {
    return _TranslationProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TranslationProgressProvider && other.projectId == projectId;
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
mixin TranslationProgressRef on AutoDisposeProviderRef<double> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _TranslationProgressProviderElement
    extends AutoDisposeProviderElement<double> with TranslationProgressRef {
  _TranslationProgressProviderElement(super.provider);

  @override
  String get projectId => (origin as TranslationProgressProvider).projectId;
}

String _$availableTargetLanguagesHash() =>
    r'b0d5ca032167de99d5dcee0dea176c3b54f97a5c';

/// See also [availableTargetLanguages].
@ProviderFor(availableTargetLanguages)
const availableTargetLanguagesProvider = AvailableTargetLanguagesFamily();

/// See also [availableTargetLanguages].
class AvailableTargetLanguagesFamily extends Family<List<String>> {
  /// See also [availableTargetLanguages].
  const AvailableTargetLanguagesFamily();

  /// See also [availableTargetLanguages].
  AvailableTargetLanguagesProvider call(
    String projectId,
  ) {
    return AvailableTargetLanguagesProvider(
      projectId,
    );
  }

  @override
  AvailableTargetLanguagesProvider getProviderOverride(
    covariant AvailableTargetLanguagesProvider provider,
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
  String? get name => r'availableTargetLanguagesProvider';
}

/// See also [availableTargetLanguages].
class AvailableTargetLanguagesProvider
    extends AutoDisposeProvider<List<String>> {
  /// See also [availableTargetLanguages].
  AvailableTargetLanguagesProvider(
    String projectId,
  ) : this._internal(
          (ref) => availableTargetLanguages(
            ref as AvailableTargetLanguagesRef,
            projectId,
          ),
          from: availableTargetLanguagesProvider,
          name: r'availableTargetLanguagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableTargetLanguagesHash,
          dependencies: AvailableTargetLanguagesFamily._dependencies,
          allTransitiveDependencies:
              AvailableTargetLanguagesFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  AvailableTargetLanguagesProvider._internal(
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
  Override overrideWith(
    List<String> Function(AvailableTargetLanguagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableTargetLanguagesProvider._internal(
        (ref) => create(ref as AvailableTargetLanguagesRef),
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
  AutoDisposeProviderElement<List<String>> createElement() {
    return _AvailableTargetLanguagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableTargetLanguagesProvider &&
        other.projectId == projectId;
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
mixin AvailableTargetLanguagesRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _AvailableTargetLanguagesProviderElement
    extends AutoDisposeProviderElement<List<String>>
    with AvailableTargetLanguagesRef {
  _AvailableTargetLanguagesProviderElement(super.provider);

  @override
  String get projectId =>
      (origin as AvailableTargetLanguagesProvider).projectId;
}

String _$translationNotifierHash() =>
    r'7f2fa46fba56a8af6bba89495140fcec64e7de75';

abstract class _$TranslationNotifier
    extends BuildlessAutoDisposeNotifier<TranslationState> {
  late final String projectId;

  TranslationState build(
    String projectId,
  );
}

/// Provider for translation state management
///
/// Copied from [TranslationNotifier].
@ProviderFor(TranslationNotifier)
const translationNotifierProvider = TranslationNotifierFamily();

/// Provider for translation state management
///
/// Copied from [TranslationNotifier].
class TranslationNotifierFamily extends Family<TranslationState> {
  /// Provider for translation state management
  ///
  /// Copied from [TranslationNotifier].
  const TranslationNotifierFamily();

  /// Provider for translation state management
  ///
  /// Copied from [TranslationNotifier].
  TranslationNotifierProvider call(
    String projectId,
  ) {
    return TranslationNotifierProvider(
      projectId,
    );
  }

  @override
  TranslationNotifierProvider getProviderOverride(
    covariant TranslationNotifierProvider provider,
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
  String? get name => r'translationNotifierProvider';
}

/// Provider for translation state management
///
/// Copied from [TranslationNotifier].
class TranslationNotifierProvider extends AutoDisposeNotifierProviderImpl<
    TranslationNotifier, TranslationState> {
  /// Provider for translation state management
  ///
  /// Copied from [TranslationNotifier].
  TranslationNotifierProvider(
    String projectId,
  ) : this._internal(
          () => TranslationNotifier()..projectId = projectId,
          from: translationNotifierProvider,
          name: r'translationNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$translationNotifierHash,
          dependencies: TranslationNotifierFamily._dependencies,
          allTransitiveDependencies:
              TranslationNotifierFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  TranslationNotifierProvider._internal(
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
  TranslationState runNotifierBuild(
    covariant TranslationNotifier notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(TranslationNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TranslationNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<TranslationNotifier, TranslationState>
      createElement() {
    return _TranslationNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TranslationNotifierProvider && other.projectId == projectId;
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
mixin TranslationNotifierRef
    on AutoDisposeNotifierProviderRef<TranslationState> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _TranslationNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TranslationNotifier,
        TranslationState> with TranslationNotifierRef {
  _TranslationNotifierProviderElement(super.provider);

  @override
  String get projectId => (origin as TranslationNotifierProvider).projectId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
