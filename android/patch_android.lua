#!/usr/bin/luajit
--A script for patching the Android build files

local GITHUB_WORKSPACE = os.getenv("GITHUB_WORKSPACE") --Get the github workspace location
assert(GITHUB_WORKSPACE, "This script has to be used inside of Github Actions environment!")
dofile(GITHUB_WORKSPACE.."/lua_utils/shared.lua") --Load the shared utilities

--== Patch /app/build.gradle ==--

print(string.rep("-",40))

do
    print("Patching /love_android/app/build.gradle...")
    local data = fs.read("/love_android/app/build.gradle")

    do
        print("Replacing applicationId...")
        local result, occurrences = data:gsub('applicationId "org.love2d.android"', 'applicationId "me.ramilego4game.liko12"')
        assert(occurrences == 1, "Failed to patch applicationId!")
        data = result
    end

    do
        print("Replacing VersionCode...")
        local result, occurrences = data:gsub("versionCode %d%d", "versionCode "..ANDROID_VERSION_CODE)
        assert(occurrences == 1, "Failed to patch VersionCode!")
        data = result
    end

    do
        print("Replacing VersionName...")
        local result, occurrences = data:gsub('versionName ".-"', 'versionName "'..LIKO_VERSION..'"')
        assert(occurrences == 1, "Failed to patch VersionName!")
        data = result
    end
    
    fs.write("/love_android/app/build.gradle", data)
    print("Patched /love_android/app/build.gradle successfully!")
end

print(string.rep("-",40))

--== Inject in lua-sec code ==--

do
    print("Patching /love_android/love/src/jni/love/Android.mk...")
    local data = fs.read("/love_android/love/src/jni/love/Android.mk")

    do
        print("Injecting LOCAL_C_INCLUDES entries...")
        local result, occurrences = data:gsub("%${LOCAL_PATH}/src/libraries/ \\","${LOCAL_PATH}/src/libraries/ \\\n${LOCAL_PATH}/src/libraries/luasocket \\\n${LOCAL_PATH}/../openssl/include \\")
        assert(occurrences == 1, "Failed to patch LOCAL_C_INCLUDES!")
        data = result
    end

    do
        print("Injecting LOCAL_SRC_FILES entries...")
        local result, occurrences = data:gsub(" \\\n  %)%)"," \\\n  $(wildcard ${LOCAL_PATH}/src/libraries/luasec/*.cpp) \\\n  $(wildcard ${LOCAL_PATH}/src/libraries/luasec/*.c) \\\n  ))")
        assert(occurrences == 1, "Failed to patch LOCAL_SRC_LIBRARIES!")
        data = result
    end

    do
        print("Injecting LOCAL_STATIC_LIBRARIES entries...")
        local result, occurrences = data:gsub("LOCAL_STATIC_LIBRARIES := ","LOCAL_STATIC_LIBRARIES := libssl libcrypto ")
        assert(occurrences == 1, "Failed to patch LOCAL_STATIC_LIBRARIES!")
        data = result
    end

    fs.write("/love_android/love/src/jni/love/Android.mk", data)
    print("Patched /love_android/love/src/jni/love/Android.mk successfully!")
end

print(string.rep("-",40))

do
    print("Patching /love_android/love/src/jni/love/src/common/config.h...")
    local data = fs.read("/love_android/love/src/jni/love/src/common/config.h")

    do
        print("Injecting LOVE_ENABLE_LUASEC")
        local result, occurrences = data:gsub("#	define LOVE_ENABLE_LUASOCKET", "#	define LOVE_ENABLE_LUASOCKET\n#define	LOVE_ENABLE_LUASEC")
        assert(occurrences == 1, "Failed to inject LOVE_ENABLE_LUASEC")
        data = result
    end

    fs.write("/love_android/love/src/jni/love/src/common/config.h", data)
    print("Patched /love_android/love/src/jni/love/src/common/config.h successfully!")
end

print(string.rep("-",40))

do
    print("Patching /love_android/love/src/jni/love/src/modules/love/love.cpp...")
    local data = fs.read("/love_android/love/src/jni/love/src/modules/love/love.cpp")

    do
        print("Injecting lua-sec include")
        local result, occurrences = data:gsub("#ifdef LOVE_ENABLE_ENET\n#",'#ifdef LOVE_ENABLE_LUASEC\n#\tinclude "libraries/luasec/luasec.h"\n#endif\n#ifdef LOVE_ENABLE_ENET\n#')
        assert(occurrences == 1, "Failed to inject luasec include!")
        data = result
    end

    do
        print("Injecting lua-sec open")
        local result, occurrences = data:gsub("#ifdef LOVE_ENABLE_ENET\n\t",'#ifdef LOVE_ENABLE_LUASEC\n\tluasec::__open(L);\n#endif\n#ifdef LOVE_ENABLE_ENET\n\t')
        assert(occurrences == 1, "Failed to inject luasec open!")
        data = result
    end

    fs.write("/love_android/love/src/jni/love/src/modules/love/love.cpp", data)
    print("Patched /love_android/love/src/jni/love/src/modules/love/love.cpp successfully!")
end

print(string.rep("-",40))