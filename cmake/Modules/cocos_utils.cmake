

macro(cocos2d_config)
    # define
    define_for_target("cocos2d" "$<$<CONFIG:Debug>:COCOS2D_DEBUG=1>")
    if(APPLE)
        define_for_target("cocos2d" __APPLE__)
        define_for_target("cocos2d" USE_FILE32API)
    elseif(ANDROID)
        define_for_target(ANDROID)
        define_for_target(USE_FILE32API)
    elseif(WINDOWS)
        compile_append_target_property(cocos2d PUBLIC_COMPILE_DEFINITIONS 
          CC_STATIC
          WIN32
          _WIN32
          _WINDOWS
          NOMINMAX
          UNICODE
          _UNICODE
          _CRT_SECURE_NO_WARNINGS
          _SCL_SECURE_NO_WARNINGS
          _USRLIBSIMSTATIC
          SE_ENABLE_INSPECTOR
          )
    endif()

    define_01_for_target("cocos2d" USE_2DPHYSICS CC_USE_PHYSICS)
    define_01_for_target("cocos2d" USE_CHIPMUNK CC_ENABLE_CHIPMUNK_INTEGRATION)
    define_01_for_target("cocos2d" USE_BOX2D CC_ENABLE_BOX2D_INTEGRATION)
    define_01_for_target("cocos2d" USE_BULLET CC_ENABLE_BULLET_INTEGRATION)
    define_01_for_target("cocos2d" USE_RECAST CC_USE_NAVMESH)
    define_01_for_target("cocos2d" USE_WEBP CC_USE_WEBP)
    define_01_for_target("cocos2d" USE_PNG CC_USE_PNG)
    define_01_for_target("cocos2d" USE_JPEG CC_USE_JPEG)


    # COCOS_EXT_ENCRYPT
    if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR IOS)
        define_for_target("cocos2d" COCOS_EXT_ENCRYPT)
    endif()

    # /* common */
    define_01_for_target("cocos2d" USE_FMOD_CORE)
    define_01_for_target("cocos2d" USE_LUA53)
    define_01_for_target("cocos2d" USE_LUAJIT205)
    define_01_for_target("cocos2d" USE_LIBWEBSOCKET)
    define_01_for_target("cocos2d" USE_LIBTCP)
    define_01_for_target("cocos2d" USE_LIVE2D_VERSION2)
    define_01_for_target("cocos2d" USE_LIVE2D_VERSION3)

    # /* debug features */
    define_01_for_target("cocos2d" DEBUG_USE_CALC_REF_LEAK_DETECTION)
    define_01_for_target("cocos2d" DEBUG_USE_CHECK_SOCKET_MSG_ORDER)
    define_01_for_target("cocos2d" DEBUG_USE_CHECK_LUA_RUN_LOOP)

    # link system libs
    if(WINDOWS)
        target_link_libraries(cocos2d ws2_32 userenv psapi winmm Iphlpapi)
    elseif(ANDROID)
        target_link_libraries(cocos2d GLESv2 EGL log android OpenSLES)
    elseif(APPLE)
        target_link_libraries(cocos2d
            "-liconv"
            "-lsqlite3"
            "-framework AudioToolbox"
            "-framework Foundation"
            "-framework OpenAL"
            "-framework QuartzCore"
            "-framework GameController"
        )

        if(MACOSX)
            # todo
        elseif(IOS)
            # Locate system libraries on iOS
            target_link_libraries(cocos2d
                "-lz"
                "-framework UIKit"
                "-framework OpenGLES"
                "-framework CoreMotion"
                "-framework AVKit"
                "-framework CoreMedia"
                "-framework CoreText"
                "-framework Security"
                "-framework CoreGraphics"
                "-framework AVFoundation"
                "-framework AuthenticationServices"
                "-framework WebKit"
            )
        endif()
    endif()

    if(XCODE OR VS)
        cocos_mark_code_files("cocos2d")
    endif()

    # compile options
    if(MSVC)
        # precompiled header. Compilation time speedup ~4x.
        # https://docs.microsoft.com/en-us/cpp/build/reference/mp-build-with-multiple-processes?view=msvc-160
        compile_append_target_property(cocos2d
            SOURCES "precheader.cpp"
            COMPILE_FLAGS "/Yuprecheader.h /FIprecheader.h"
            COMPILE_OPTIONS "/MP"
            INTERFACE_COMPILE_OPTIONS "/MP"
            )
        # https://docs.microsoft.com/en-us/cpp/build/reference/yc-create-precompiled-header-file?view=msvc-160
        set_source_files_properties("${COMPILE_CUR_GENERATED_PATH}/precheader.cpp" PROPERTIES COMPILE_FLAGS "/Ycprecheader.h")
        # compile c as c++. needed for precompiled header
        get_target_property(sources cocos2d SOURCES)
        foreach(item ${sources})
            if(${item} MATCHES "\\.c$")
                set_source_files_properties(${item} PROPERTIES LANGUAGE CXX)
            endif()
        endforeach()
        unset(sources)
    endif()
endmacro()

macro(use_app_ios_libs_depend target)
    if(IOS)
        set(listIOSDependLibs)
        set(ios_specific_lib_path ${COCOS2DX_ROOT_PATH}/external/ext_third_party/ios-specific)
        set(ios_specific_lib_bin_path ${ENGINE_BINARY_PATH}/external/ext_third_party/ios-specific)

        add_subdirectory(${ios_specific_lib_path}/zap ${ios_specific_lib_bin_path}/zap)

        list(APPEND listIOSDependLibs
            "-framework CFNetwork"
            "-framework CoreTelephony"
            "-framework SystemConfiguration"
            "-framework StoreKit"
            "-framework Photos"
            "-framework PhotosUI"
            "-framework AddressBook"
            "-framework MessageUI"
            "-framework MobileCoreServices"
            "-framework AssetsLibrary"
            "-framework AdSupport"
            "-framework iAd"
            "-weak_framework AppTrackingTransparency"

            ext_zap
            )

        if (IOS_USE_BUGLY)
            add_subdirectory(${ios_specific_lib_path}/BuglyAgent ${ios_specific_lib_bin_path}/BuglyAgent)
            list(APPEND listIOSDependLibs
                ${ios_specific_lib_path}/frameworks/Bugly.framework
                ext_bugly
                )
        endif()


        if (IOS_USE_UMENG)
            message(STATUS IOS_USE_UMENG)
            list(APPEND listIOSDependLibs
                ${ios_specific_lib_path}/frameworks/Umeng/common/common_ios_2.1.4/normal/UMCommon.framework
                ${ios_specific_lib_path}/frameworks/Umeng/analytics/analytics_ios_6.1.0+G/UMAnalytics.framework
                )
        endif()

        if (IOS_USE_SENSORS)
            message(STATUS IOS_USE_SENSORS)
            list(APPEND listIOSDependLibs
                -force_load ${ios_specific_lib_path}/frameworks/SensorsAnalyticsSDK.framework/SensorsAnalyticsSDK
                )
        endif()

        if (IOS_USE_WECHAT_SHARE)
            message(STATUS IOS_USE_WECHAT_SHARE)
            add_subdirectory(${ios_specific_lib_path}/Wechat ${ios_specific_lib_bin_path}/Wechat)
            target_link_libraries(${target} -force_load)
            target_link_libraries(${target} ext_wechat)
        endif()

        if (IOS_USE_ADJUST_STATISTICS_SDK)
            message(STATUS IOS_USE_ADJUST_STATISTICS_SDK)
            add_subdirectory(${ios_specific_lib_path}/adjust ${ios_specific_lib_bin_path}/adjust)
            list(APPEND listIOSDependLibs
                ext_adjust
                )
        endif()

        if (IOS_USE_NATIVE_LOCATION)
            message(STATUS IOS_USE_NATIVE_LOCATION)
            find_library(CORELOCATION_LIBRARY CoreLocation)
            list(APPEND listIOSDependLibs
                ${CORELOCATION_LIBRARY}
                )
        endif()

        
        if (IOS_USE_SYSTEM_RECORD_INTERFACE)
            message(STATUS IOS_USE_SYSTEM_RECORD_INTERFACE)
            add_subdirectory(${ios_specific_lib_path}/lame ${ios_specific_lib_bin_path}/lame)
            target_link_libraries(${target} ext_lame)
        endif()


        foreach(item ${listIOSDependLibs})
            message(STATUS IOS depend libs: ${item})
            target_link_libraries(${target} ${item})
        endforeach(item)

        compile_append_target_property(${target} 
            INCLUDE_DIRECTORIES proj.ios_mac/ios
        )

        # ios sdk
        define_01_for_target(${APP_NAME} IOS_USE_UMENG)
        define_01_for_target(${APP_NAME} IOS_USE_FACEBOOK_SHARE_AND_LOGIN)
        define_01_for_target(${APP_NAME} IOS_USE_WECHAT_SHARE)
        define_01_for_target(${APP_NAME} IOS_USE_NATIVE_LOCATION)
        define_01_for_target(${APP_NAME} IOS_USE_ADJUST_STATISTICS_SDK)
        define_01_for_target(${APP_NAME} IOS_USE_SYSTEM_RECORD_INTERFACE)
        define_01_for_target(${APP_NAME} IOS_USE_APPSFLYER_SDK)
        define_01_for_target(${APP_NAME} IOS_USE_SENSORS)
        define_01_for_target(${APP_NAME} IOS_USE_BUGLY)
        define_01_for_target(${APP_NAME} IOS_USE_SAWA)
        define_01_for_target(${APP_NAME} IOS_USE_FIREBASE_ANALYTICS_SDK)
    endif()
endmacro()

# setup a cocos application
function(setup_cocos_app_config target)
    print("setup_cocos_app_config:${target}")
    use_app_ios_libs_depend(${target})

    # put all output app into bin/${target}
    set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/${target}")
    if(APPLE)
        # output macOS/iOS .app
        set_target_properties(${target} PROPERTIES MACOSX_BUNDLE 1)
    elseif(MSVC)
        # visual studio default is Console app, but we need Windows app
        set_property(TARGET ${target} APPEND PROPERTY LINK_FLAGS "/SUBSYSTEM:WINDOWS")
    endif()

    # auto mark code files for IDE when mark app
    if(XCODE OR VS)
        cocos_mark_code_files(${target})
    endif()
endfunction()
