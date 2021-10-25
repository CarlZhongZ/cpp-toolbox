# ---------------------- common utils begin
macro(print)
    message(STATUS ${ARGN})
endmacro()

macro(error)
    message(FATAL_ERROR "!!!!!${ARGN}")
endmacro()

macro(print_var NAME)
    message(STATUS "VAR[${NAME}]:${${NAME}}")
endmacro()

macro(print_env NAME)
    message(STATUS "ENV[${NAME}]:$ENV{${NAME}}")
endmacro()

function(print_prop NAME)
    get_property(VAL GLOBAL PROPERTY ${NAME})
    message(STATUS "PROP[${NAME}]:${VAL}")
endfunction()

macro(set_if_undefined varname value)
    if(NOT DEFINED ${varname})
        set(${varname} ${value})
    endif()
endmacro()

function(utils_split list split outVar)
    set(retList)
    string(LENGTH ${split} lenSplit)

    foreach(item ${list})
        string(FIND ${item} ${split} index)
        while(NOT index EQUAL -1)
            string(SUBSTRING ${item} 0 ${index} subStr)
            if(subStr)
                list(APPEND retList ${subStr})
            endif()

            math(EXPR subIndex "${index} + ${lenSplit}" OUTPUT_FORMAT DECIMAL)    
            string(SUBSTRING ${item} ${subIndex} -1 item)

            string(FIND ${item} ${split} index)
        endwhile()

        list(APPEND retList ${item})
    endforeach()

    set(${outVar} ${retList} PARENT_SCOPE)
endfunction()

function(utils_gen_path listPathName outVar)
    utils_split("${listPathName}" "/" outList)

    set(pathList)
    foreach(item ${outList})
        if(item STREQUAL "..")
            list(POP_BACK pathList)
        elseif(NOT item STREQUAL ".")
            list(APPEND pathList ${item})
        endif()
    endforeach()

    list(JOIN pathList "/" ret)
    set(${outVar} ${ret} PARENT_SCOPE)
endfunction()

macro(_saveFuncParentScopeValue varName)
    set(${varName} ${${varName}} PARENT_SCOPE)
endmacro()

macro(_saveFuncParentScopeValueNull varName)
    set(${varName} PARENT_SCOPE)
endmacro()

# get all linked libraries including transitive ones, recursive
function(search_depend_libs_recursive target all_depends_out)
    set(all_depends_inner)
    set(targets_prepare_search ${target})
    while(true)
        foreach(tmp_target ${targets_prepare_search})
            get_target_property(tmp_depend_libs ${tmp_target} LINK_LIBRARIES)
            list(REMOVE_ITEM targets_prepare_search ${tmp_target})
            list(APPEND tmp_depend_libs ${tmp_target})
            foreach(depend_lib ${tmp_depend_libs})
                if(TARGET ${depend_lib})
                    list(APPEND all_depends_inner ${depend_lib})
                    if(NOT (depend_lib STREQUAL tmp_target))
                        list(APPEND targets_prepare_search ${depend_lib})
                    endif()
                endif()
            endforeach()
        endforeach()
        list(LENGTH targets_prepare_search targets_prepare_search_size)
        if(targets_prepare_search_size LESS 1)
            break()
        endif()
    endwhile(true)
    set(${all_depends_out} ${all_depends_inner} PARENT_SCOPE)
endfunction()

# get `cocos_target` depend all dlls, save the result in `all_depend_dlls_out`
function(get_target_depends_ext_dlls cocos_target all_depend_dlls_out)
    set(depend_libs)
    set(all_depend_ext_dlls)
    search_depend_libs_recursive(${cocos_target} depend_libs)
    foreach(depend_lib ${depend_libs})
        if(TARGET ${depend_lib})
            get_target_property(found_shared_lib ${depend_lib} IMPORTED_IMPLIB)
            if(found_shared_lib)
                get_target_property(tmp_dlls ${depend_lib} IMPORTED_LOCATION)
                list(APPEND all_depend_ext_dlls ${tmp_dlls})
            endif()
        endif()
    endforeach()

    set(${all_depend_dlls_out} ${all_depend_ext_dlls} PARENT_SCOPE)
endfunction()

# copy the `cocos_target` needed dlls into TARGET_FILE_DIR
function(cocos_copy_target_dll cocos_target)
    get_target_depends_ext_dlls(${cocos_target} all_depend_dlls)
    # remove repeat items
    if(all_depend_dlls)
        list(REMOVE_DUPLICATES all_depend_dlls)
    endif()
    foreach(cc_dll_file ${all_depend_dlls})
        get_filename_component(cc_dll_name ${cc_dll_file} NAME)
        add_custom_command(TARGET ${cocos_target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E echo "copy dll into target file dir: ${cc_dll_name} ..."
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${cc_dll_file} "$<TARGET_FILE_DIR:${cocos_target}>/${cc_dll_name}"
        )
    endforeach()
endfunction()

# mark the code sources of `cocos_target` into sub-dir tree
function(cocos_mark_code_files cocos_target)
    set(oneValueArgs GROUPBASE)
    cmake_parse_arguments(opt "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    if(NOT opt_GROUPBASE)
        set(root_dir ${CMAKE_CURRENT_SOURCE_DIR})
    else()
        set(root_dir ${opt_GROUPBASE})
        message(STATUS "target ${cocos_target} code group base is: ${root_dir}")
    endif()

    message(STATUS "cocos_mark_code_files: ${cocos_target}")

    get_property(file_list TARGET ${cocos_target} PROPERTY SOURCES)

    foreach(single_file ${file_list})
        source_group_single_file(${single_file} GROUP_TO "Source Files" BASE_PATH "${root_dir}")
    endforeach()
endfunction()

# source group one file
# cut the `single_file` absolute path from `BASE_PATH`, then mark file to `GROUP_TO`
function(source_group_single_file single_file)
    set(oneValueArgs GROUP_TO BASE_PATH)
    cmake_parse_arguments(opt "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    # get relative_path
    get_filename_component(abs_path ${single_file} ABSOLUTE)
    file(RELATIVE_PATH relative_path_with_name ${opt_BASE_PATH} ${abs_path})
    get_filename_component(relative_path ${relative_path_with_name} PATH)
    # set source_group, consider sub source group
    string(REPLACE "/" "\\" ide_file_group "${relative_path}")
    source_group("${ide_file_group}" FILES ${single_file})
endfunction()

macro(init_build)
    print_var(PROJECT_NAME)
    print_var(PROJECT_SOURCE_DIR)
    print_var(PROJECT_BINARY_DIR)
    print_var(CMAKE_MODULE_PATH)
    print_var(CMAKE_C_COMPILER)
    print_var(CMAKE_CXX_COMPILER)
    print_var(ENGINE_BINARY_PATH)

    # CMAKE_TOOLCHAIN_FILE
    if(CMAKE_TOOLCHAIN_FILE)
        print_var(CMAKE_TOOLCHAIN_FILE)
    endif()

    # build type
    if(NOT CMAKE_BUILD_TYPE IN_LIST "Debug:Release")
        set(CMAKE_BUILD_TYPE "Debug")
    endif()
    print_var(CMAKE_BUILD_TYPE)

    # todo: support multiple build configerations
    set(CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}")  # Debug;Release;MinSizeRel;RelWithDebInfo
    # print_var(CMAKE_CONFIGURATION_TYPES)

    # check c++ standard
    message(STATUS "\n-------------------------------")
    set(CMAKE_C_STANDARD 99)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)

    # print_prop(CMAKE_C_KNOWN_FEATURES)
    # print_var(CMAKE_C_COMPILE_FEATURES)
    # print_var(CMAKE_C_EXTENSIONS)
    # print_var(CMAKE_C_STANDARD)
    # print_var(CMAKE_C_STANDARD_REQUIRED)

    # print_prop(CMAKE_CXX_KNOWN_FEATURES)
    # print_var(CMAKE_CXX_COMPILE_FEATURES)
    # print_var(CMAKE_CXX_EXTENSIONS)
    # print_var(CMAKE_CXX_STANDARD)
    # print_var(CMAKE_CXX_STANDARD_REQUIRED)

    # todo: use swift or not?
    # Swift 4.0 for Xcode 10.2 and above.
    # Swift 3.0 for Xcode 8.3 and above.
    # Swift 2.3 for Xcode 8.2 and below.
    # print_var(CMAKE_Swift_LANGUAGE_VERSION)
    message(STATUS "-------------------------------\n")

    # generators that are capable of organizing into a hierarchy of folders
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)


    # WIN32 Set to True when the target system is Windows, including Win64
    # MSVC Set to true when the compiler is some version of Microsoft Visual C++ or another compiler simulating Visual C++. Any compiler defining _MSC_VER is considered simulating Visual C++
    # APPLE Set to True when the target system is an Apple platform (macOS, iOS, tvOS or watchOS)
    # XCODE True when using Xcode generator
    # IOS Set to 1 when the target system (CMAKE_SYSTEM_NAME) is iOS
    # ANDROID Set to 1 when the target system (CMAKE_SYSTEM_NAME) is Android

    print_var(CMAKE_SYSTEM)
    print_var(CMAKE_GENERATOR)
    if(MSVC)
        print_var(WIN32)
        print_var(MSVC)
        print_var(MSVC_VERSION)
        print_var(MSVC_IDE)
        print_var(MSVC_TOOLSET_VERSION)

        # Visual Studio 2015, MSVC_VERSION 1900      (v140 toolset)
        # Visual Studio 2017, MSVC_VERSION 1910-1919 (v141 toolset)
        if(${MSVC_VERSION} LESS 1900)
            error("using Windows MSVC generate cocos2d-x project, MSVC_VERSION:${MSVC_VERSION} lower than needed")
        endif()

        set(WINDOWS TRUE)
        set(VS TRUE)
    elseif(APPLE)
        print_var(APPLE)
        print_var(XCODE)
        print_var(XCODE_VERSION)
        print_var(IOS)

        if(NOT IOS)
            set(MACOSX TRUE)
        endif()
    elseif(ANDROID)
        print_var(ANDROID)
    else()
        error("Unsupported platform:${CMAKE_SYSTEM_NAME}, CMake will exit")
    endif()


    # PLATFORM_FOLDER
    if(WINDOWS)
        if (CMAKE_SIZEOF_VOID_P EQUAL 64)
            set(PLATFORM_FOLDER "win64")
        else()
            set(PLATFORM_FOLDER "win32")
        endif()
    elseif(ANDROID)
        set(PLATFORM_FOLDER "android/${ANDROID_ABI}")
    elseif(IOS)
        set(PLATFORM_FOLDER "ios")
    elseif(MACOSX)
        set(PLATFORM_FOLDER "mac")
    else()
        message(FATAL_ERROR "platform not supported")
    endif()

	# print cmake debug info
	set(CMAKE_DEBUG_TARGET_PROPERTIES
	    # AUTOUIC_OPTIONS
	    # COMPILE_DEFINITIONS
	    # COMPILE_FEATURES
	    # COMPILE_OPTIONS
	    # INCLUDE_DIRECTORIES
	    # LINK_DIRECTORIES
	    # LINK_OPTIONS
	    # POSITION_INDEPENDENT_CODE
	    # SOURCES
	)
endmacro()
