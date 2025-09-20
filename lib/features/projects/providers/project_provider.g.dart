// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$projectsStreamHash() => r'e1c147dcdbe68e668571825e5ab9f76d5d2a7a24';

/// See also [projectsStream].
@ProviderFor(projectsStream)
final projectsStreamProvider =
    AutoDisposeStreamProvider<List<ProjectModel>>.internal(
  projectsStream,
  name: r'projectsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$projectsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectsStreamRef = AutoDisposeStreamProviderRef<List<ProjectModel>>;
String _$projectsNotifierHash() => r'1d94664940f874e72ecdcf838f39f4796d7ab6a3';

/// See also [ProjectsNotifier].
@ProviderFor(ProjectsNotifier)
final projectsNotifierProvider =
    AutoDisposeNotifierProvider<ProjectsNotifier, String>.internal(
  ProjectsNotifier.new,
  name: r'projectsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$projectsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProjectsNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
