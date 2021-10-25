


# the default behavior of using prebuilt
option(USE_2DPHYSICS "Use 2D physics library" ON)
option(USE_CHIPMUNK "Use chipmunk for physics library" ON)
option(USE_BOX2D "Use box2d for physics library" OFF)

if (USE_2DPHYSICS)
	if (NOT USE_CHIPMUNK AND NOT USE_BOX2D)
		message(FATAL_ERROR "USE_2DPHYSICS USE_CHIPMUNK or USE_BOX2D must be TRUE")
	endif()
endif()

option(USE_BULLET "Use bullet for physics3d library" OFF)
option(USE_RECAST "Use Recast for navigation mesh" OFF)
option(USE_WEBP "Use WebP codec" OFF)
option(USE_PNG "Use PNG codec" ON)
option(USE_JPEG "Use JPEG codec" ON)


# optional libs
option(USE_FMOD_CORE "help string describing USE_FMOD_CORE" ON)
option(USE_LUA53 "help string describing use lua 5.3" OFF)
option(USE_LUAJIT205 "help string describing use USE_LUAJIT205" OFF)
option(USE_LIBWEBSOCKET "USE_LIBWEBSOCKET" ON)
option(USE_LIBTCP "USE_LIBTCP" ON)
option(USE_LIVE2D_VERSION2 "help string describing USE_LIVE2D_VERSION2" ON)
option(USE_LIVE2D_VERSION3 "help string describing USE_LIVE2D_VERSION3" OFF)

# debug
option(DEBUG_USE_CALC_REF_LEAK_DETECTION "help string describing DEBUG_USE_CALC_REF_LEAK_DETECTION" OFF)
option(DEBUG_USE_CHECK_SOCKET_MSG_ORDER "help string describing DEBUG_USE_CHECK_SOCKET_MSG_ORDER" OFF)
option(DEBUG_USE_CHECK_LUA_RUN_LOOP "help string describing DEBUG_USE_CHECK_LUA_RUN_LOOP" OFF)

# /w, /W0, /W1, /W2, /W3, /W4, /w1, /w2, /w3, /w4, /Wall, /wd, /we, /wo, /Wv, /WX
# https://docs.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level?view=msvc-160
option(DEBUG_WARNING_LEVEL "编译警告的时候报错" OFF)


if (IOS)
	# optional ios libs
	option(IOS_USE_FACEBOOK_SHARE_AND_LOGIN "using facebook login and share sdk" OFF)
	option(IOS_USE_WECHAT_SHARE "using wechat share sdk" OFF)
	option(IOS_USE_NATIVE_LOCATION "using location sdk" OFF)
	option(IOS_USE_ADJUST_STATISTICS_SDK "using adjust statistics sdk" OFF)
	option(IOS_USE_SYSTEM_RECORD_INTERFACE "using system record interface" OFF)
	option(IOS_USE_APPSFLYER_SDK "help string describing IOS_USE_APPSFLYER_SDK" OFF)
	option(IOS_USE_UMENG "help string describing IOS_USE_UMENG" ON)
	option(IOS_USE_SENSORS "using sensor analysics IOS_USE_SENSORS" OFF)
	option(IOS_USE_BUGLY "using sensor analysics IOS_USE_BUGLY" ON)
	option(IOS_USE_FIREBASE_ANALYTICS_SDK "using firebase analytics IOS_USE_FIREBASE_ANALYTICS_SDK" OFF)
endif()
