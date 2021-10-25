# compile utilities
include(compile_utils_define)

macro(compile_push_dir d)
    # print("compile_push_dir:${d}")
    list(APPEND COMPILE_CUR_PATH ${d})
    utils_gen_path("${COMPILE_CUR_PATH}" COMPILE_CUR_GENERATED_PATH)
endmacro()

macro(compile_pop_dir)
    # print(compile_pop_dir)
    list(POP_BACK COMPILE_CUR_PATH)
    utils_gen_path("${COMPILE_CUR_PATH}" COMPILE_CUR_GENERATED_PATH)
endmacro()

# include CMakeLists.txt directory
macro(compile_include path)
    compile_push_dir(${path})

    _getFullPath(tmpIncludePath "CMakeLists.txt")
    print("----parse code in:${tmpIncludePath}")
    include(${tmpIncludePath})

    compile_pop_dir()
endmacro()

function(compile_append_attr)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs "${__TARGET_ATTR}")
    cmake_parse_arguments("opt" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    foreach(propName ${__TARGET_ATTR})
        if(DEFINED opt_${propName})
            _transformPath("${propName}" opt_${propName})
            if(NOT DEFINED GLOBAL_COMPILE_ATTR_${propName})
                set(GLOBAL_COMPILE_ATTR_${propName})
            endif()
            list(APPEND GLOBAL_COMPILE_ATTR_${propName} "${opt_${propName}}")
            _saveFuncParentScopeValue(GLOBAL_COMPILE_ATTR_${propName})
        endif()
    endforeach()
endfunction()

macro(compile_source)
    compile_append_attr(
        SOURCES "${ARGN}"
        )
endmacro()

macro(compile_add_resource)
    compile_append_attr(
        RESOURCE "${ARGN}"
        SOURCES "${ARGN}"
        )
endmacro()

# 构建当前的库
function(compile_add_library name)
    print("compile_add_library:${name}")

    set(options SHARED STATIC EXECUTABLE)
    set(oneValueArgs)
    set(multiValueArgs "${__TARGET_ATTR}")
    cmake_parse_arguments("opt" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(opt_SHARED)
        add_library(${name} SHARED IMPORTED GLOBAL)
    elseif(opt_STATIC)
        if(DEFINED opt_SOURCES OR DEFINED GLOBAL_COMPILE_ATTR_SOURCES)
            add_library(${name} STATIC)
        else()
            add_library(${name} STATIC IMPORTED GLOBAL)
        endif()
    elseif(opt_EXECUTABLE)
        add_executable(${name})
    else()
        error("invalid parms")
    endif()

    foreach(propName ${__TARGET_ATTR})
        if(DEFINED opt_${propName})
            _transformPath("${propName}" opt_${propName})
            _appendTargetProperty(${name} "${propName}" "${opt_${propName}}")
        endif()

        if(DEFINED GLOBAL_COMPILE_ATTR_${propName})
            _appendTargetProperty(${name} "${propName}" "${GLOBAL_COMPILE_ATTR_${propName}}")
            unset(GLOBAL_COMPILE_ATTR_${propName} PARENT_SCOPE)
        endif()
    endforeach()
endfunction()


# compile binary libs utils target attrs
set(COMPILE_BIN_LIBS)
macro(compile_add_external_library name)
    compile_add_library(${name} ${ARGN})
    set_target_properties(${name} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
            FOLDER "External"
        )
    list(APPEND COMPILE_BIN_LIBS ${name})
endmacro()

function(compile_link_external_libs_to_target name)
    print("compile_link_external_libs_to_target:${name}")

    foreach(item ${COMPILE_BIN_LIBS})
    	print(${item})
        target_link_libraries(${name} ${item})
    endforeach()
    set(COMPILE_BIN_LIBS PARENT_SCOPE)
endfunction()

function(compile_append_target_property target)
    # print("compile_append_target_property:${target}")

    set(options)
    set(oneValueArgs)
    set(multiValueArgs "${__TARGET_ATTR}")
    cmake_parse_arguments("opt" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    foreach(propName ${__TARGET_ATTR})
        if(DEFINED opt_${propName})
            _transformPath("${propName}" opt_${propName})
            _appendTargetProperty(${target} "${propName}" "${opt_${propName}}")
        endif()
    endforeach()
endfunction()

macro(define_for_target target def)
    compile_append_target_property(${target}
        PUBLIC_COMPILE_DEFINITIONS "${def}"
        )
endmacro()

function(define_01_for_target target useVar)
    set(definedName ${ARGN1})
    if(NOT definedName)
        set(definedName ${useVar})
    endif()

    if (${useVar})
        compile_append_target_property(${target}
            COMPILE_DEFINITIONS "${definedName}=1"
            )
    else()
        compile_append_target_property(${target}
            COMPILE_DEFINITIONS "${definedName}=0"
            )
    endif()
endfunction()
