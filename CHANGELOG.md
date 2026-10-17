## 2026-10-17

* Bump Intel IPP on Windows to 2026.1.0.761

## 2026-10-10

* Add PamplejuceIOS.cmake helpers for JUCE host-tool builds, iOS plugin options, AUv3 bundle IDs, archive symbols, and Swift libraries.
* Use PAMPLEJUCE_IOS_DEPLOYMENT_TARGET (default 15.0) for iOS builds instead of the macOS deployment target.
* Skip console test and benchmark targets on iOS.

## 2026-08-16

* Add PamplejuceFunctions.cmake: one include() that defines all pamplejuce_* functions and turns off their legacy include-time behavior
* Fix catch_discover_tests call so DISCOVERY_MODE PRE_TEST actually applies (was silently falling back to POST_BUILD)
* Rename the internal flag to _PAMPLEJUCE_USE_FUNCTIONS (PAMPLEJUCE_MULTI_PRODUCT is gone: include PamplejuceFunctions.cmake instead of setting a flag)
* Rename function argument prefixes from PJ_ to PAMP_ (internal only, no API change)

## 2025-12-26

* PAMPLEJUCE_IPP will now be true on Linux and macOS Intel
* Bump Intel IPP to 2022.3.0.387
* Bump CPM to 0.42.0

## 2025-06-17

*  Bump to C++23

## 2025-05-06

* Bump Catch2 to 3.8.1

## 2024-08-12

* Bump to Catch2 v3.7.0
* No longer try to build universal binaries on iOS.
* Fix issue with Benchmark globs not pulling in .h files.
* Instead of linking like so `target_link_libraries(Benchmarks PRIVATE SharedCode Catch2::Catch2WithMain)` we now link like so `target_link_libraries(Benchmarks PRIVATE SharedCode Catch2::Catch2)`. This allows us to run JUCE's `ScopedJuceInitialiser_GUI` inside Catch2 for the duration of the tests, see Pamplejuce for the implementation.

## 2024-07-23

* Bumping VERSION now will reconfigure CMake to pick up new the version

## 2024-06-19

* Static link the Visual C++ Redistributable on Windows

## 2024-06-07

* Bump to Catch2 v3.6.0

## 2024-02-06

* Enforce that targeting macOS down to 10.13 via CMAKE_OSX_DEPLOYMENT_TARGET

## 2023-09-04

* Added `SharedCodeDefaults.cmake` which handles setting C++20 and fast math on the `SharedCode` Target.
* Modified CTest to report on failure

## 2023-09-04

Initial commit. Added this CHANGELOG.
