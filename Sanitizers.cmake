# include() this AFTER project(): the blocks below gate on CMAKE_CXX_COMPILER_ID / MSVC,
# which are only populated once the compiler is detected. Included earlier they silently no-op.
option(WITH_ADDRESS_SANITIZER "Enable Address Sanitizer" OFF)
option(WITH_THREAD_SANITIZER "Enable Thread Sanitizer" OFF)
option(WITH_REALTIME_SANITIZER "Enable Realtime Sanitizer (RTSan)" OFF)

message(STATUS "Sanitizers: ASan=${WITH_ADDRESS_SANITIZER} TSan=${WITH_THREAD_SANITIZER} RTSan=${WITH_REALTIME_SANITIZER}")

# Fail loudly on the most common mistake (included before project()) instead of doing nothing.
if ((WITH_ADDRESS_SANITIZER OR WITH_THREAD_SANITIZER OR WITH_REALTIME_SANITIZER) AND NOT MSVC AND NOT CMAKE_CXX_COMPILER_ID)
    message(FATAL_ERROR "Sanitizers requested but no compiler detected: include(Sanitizers) must come after project().")
endif ()
if (WITH_ADDRESS_SANITIZER)
    if (MSVC)
        add_compile_options(/fsanitize=address)
    elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # also enable UndefinedBehaviorSanitizer
        # https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
        link_libraries(-fsanitize=address)
    endif ()
    message(WARNING "Address Sanitizer enabled")
endif ()

if (WITH_THREAD_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        add_compile_options(-fsanitize=thread -g -fno-omit-frame-pointer)
        link_libraries(-fsanitize=thread)
        message(WARNING "Thread Sanitizer enabled")
    endif ()
endif ()

# RealtimeSanitizer (RTSan) flags allocations, locks, and syscalls inside functions marked
# [[clang::nonblocking]] (e.g. an audio processBlock). Needs Clang >= 20. AppleClang has no
# -fsanitize=realtime, so on macOS configure with Homebrew LLVM, e.g.:
#   -DCMAKE_C_COMPILER=$(brew --prefix llvm)/bin/clang
#   -DCMAKE_CXX_COMPILER=$(brew --prefix llvm)/bin/clang++
if (WITH_REALTIME_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        add_compile_options(-fsanitize=realtime -g -fno-omit-frame-pointer)
        add_link_options(-fsanitize=realtime)

        # Homebrew clang compiles against its own newer libc++ headers, so link + rpath its
        # runtime too or the system libc++ is missing symbols like __hash_memory. Derived from
        # the compiler path and guarded, so it is a no-op on Linux or with the system libc++.
        get_filename_component(_llvm_root "${CMAKE_CXX_COMPILER}" DIRECTORY)
        get_filename_component(_llvm_root "${_llvm_root}" DIRECTORY)
        if (EXISTS "${_llvm_root}/lib/c++")
            add_link_options(-L${_llvm_root}/lib/c++ -Wl,-rpath,${_llvm_root}/lib/c++)
        endif ()
        if (EXISTS "${_llvm_root}/lib/unwind")
            add_link_options(-L${_llvm_root}/lib/unwind -lunwind -Wl,-rpath,${_llvm_root}/lib/unwind)
        endif ()
        message(WARNING "Realtime Sanitizer enabled")
    else ()
        message(FATAL_ERROR "WITH_REALTIME_SANITIZER requires Clang >= 20 (Homebrew LLVM on macOS; AppleClang has no -fsanitize=realtime)")
    endif ()
endif ()
