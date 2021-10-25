set(COMPILE_CUR_PATH)
set(COMPILE_CUR_GENERATED_PATH)

set(__CONFIGURATION_TYPES "DEBUG;RELEASE")

function(_setTargetAttrVar var)
    set(tmpRecordFullAttrs)
    foreach(prop ${ARGN})
        list(APPEND tmpRecordFullAttrs ${prop})
        foreach(item ${__CONFIGURATION_TYPES})
            list(APPEND tmpRecordFullAttrs ${prop}_${item})
        endforeach()
    endforeach()

    if(${var} STREQUAL __TARGET_ATTR)
        list(APPEND tmpRecordFullAttrs ${__PATH_ATTR_NAME})
        list(APPEND tmpRecordFullAttrs ${__PATH_OR_NOT_ATTR_NAME})
    endif()

    set(${var} "${tmpRecordFullAttrs}" PARENT_SCOPE)
endfunction()

# 扩展 PUBLIC 属性字段
set(__extPropNames 
    "PUBLIC_INCLUDE_DIRECTORIES"
    "PUBLIC_COMPILE_DEFINITIONS"
    "PUBLIC_COMPILE_OPTIONS"
)

function(_registerExtTargetProps)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs "${__extPropNames}")
    cmake_parse_arguments("" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    foreach(propName ${__extPropNames})
        set(__extProp_${propName} "${_${propName}}" PARENT_SCOPE)
        foreach(subProp ${_${propName}})
            if(subProp IN_LIST __PATH_ATTR_NAME)
                list(APPEND __PATH_ATTR_NAME "${propName}")
                list(APPEND __TARGET_ATTR "${propName}")
                _saveFuncParentScopeValue(__PATH_ATTR_NAME)
                _saveFuncParentScopeValue(__TARGET_ATTR)
            elseif(subProp IN_LIST __TARGET_ATTR)
                list(APPEND __TARGET_ATTR "${propName}")
                _saveFuncParentScopeValue(__TARGET_ATTR)
            else()
                error("public prop [${propName}] not valid subProp [${subProp}] not exists")
            endif()
            break()
        endforeach()
    endforeach()
endfunction()

# 存放路径的 target 属性
_setTargetAttrVar(__PATH_ATTR_NAME
    # 编译源代码
    SOURCES

    # Target marked with the FRAMEWORK or BUNDLE property generate framework or application bundle (both macOS and iOS is supported)
    RESOURCE

    IMPORTED_LOCATION  # 依赖静态库或者动态库
    IMPORTED_IMPLIB  # 依赖动态库时对应的静态库

    INCLUDE_DIRECTORIES  # 包含目录
    INTERFACE_INCLUDE_DIRECTORIES
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
    
    
    )

_setTargetAttrVar(__PATH_OR_NOT_ATTR_NAME
    INTERFACE_LINK_LIBRARIES  # 链接库
    )

# target 所有属性（包括路径属性）
_setTargetAttrVar(__TARGET_ATTR
    # 宏定义
    COMPILE_DEFINITIONS
    INTERFACE_COMPILE_DEFINITIONS

    # Specifies language whose compiler will invoke the linker.(such as "C" or "CXX")
    LINKER_LANGUAGE

    # target_compile_options
    COMPILE_OPTIONS
    INTERFACE_COMPILE_OPTIONS

    # Additional flags to use when compiling this target’s sources.
    # This property is deprecated. Use the COMPILE_OPTIONS property or the target_compile_options() command instead.
    COMPILE_FLAGS

    # Specify the programming language in which a source file is written. 
    # Typical values are CXX (i.e. C++), C, CSharp, CUDA, Fortran, ISPC, and ASM
    LANGUAGE

    ARCHIVE_OUTPUT_DIRECTORY
    LIBRARY_OUTPUT_DIRECTORY
    FOLDER
    )

_registerExtTargetProps(
    PUBLIC_INCLUDE_DIRECTORIES "INCLUDE_DIRECTORIES;INTERFACE_INCLUDE_DIRECTORIES"
    PUBLIC_COMPILE_DEFINITIONS "COMPILE_DEFINITIONS;INTERFACE_COMPILE_DEFINITIONS"
    PUBLIC_COMPILE_OPTIONS "COMPILE_OPTIONS;INTERFACE_COMPILE_OPTIONS"
    )

function(_appendTargetProperty target propName propValue)
    if(propName MATCHES "^PUBLIC_")
        foreach(realPropName ${__extProp_${propName}})
            set_property(TARGET ${target} APPEND
                PROPERTY ${realPropName} "${propValue}"
                )
        endforeach()
    else()
        set_property(TARGET ${target} APPEND
            PROPERTY ${propName} "${propValue}"
            )
    endif()
endfunction()

function(_getFullPath fullPathVar)
    set(fullPath)
    foreach(item ${ARGN})
        if (NOT item MATCHES "^${CMAKE_CURRENT_SOURCE_DIR}/.+")
            set(item "${CMAKE_CURRENT_SOURCE_DIR}/${COMPILE_CUR_GENERATED_PATH}/${item}")
            utils_gen_path("${item}" item)
        endif()

        if (NOT EXISTS "${item}")
            error("${item} not exists")
        endif()

        list(APPEND fullPath "${item}")
    endforeach()
    set(${fullPathVar} ${fullPath} PARENT_SCOPE)
endfunction()

function (_getSourceFullPath fullPathVar)
    set(fullPath)

    set(listPath)
    _getFullPath(listPath ${ARGN})
    foreach(item ${listPath})
        if (IS_DIRECTORY ${item})
            file(GLOB listSubFP1 ${item}/*.h)
            file(GLOB listSubFP2 ${item}/*.cpp)
            foreach(it IN LISTS listSubFP1 listSubFP2)
                list(APPEND fullPath "${it}")
            endforeach()
        else()
            list(APPEND fullPath "${item}")
        endif()
    endforeach()

    set(${fullPathVar} ${fullPath} PARENT_SCOPE)
endfunction()

# 将属于路径的属性值转换成全局路径
# 是否为存放路径的属性
function(_isTargetAttrPath attrName bIsVar)
    if(attrName IN_LIST __PATH_ATTR_NAME)
        set(${bIsVar} 1 PARENT_SCOPE)
    else()
        set(${bIsVar} 0 PARENT_SCOPE)
    endif()
endfunction()

# 将属于路径的属性值转换成全局路径
macro(_transformPath propName propNameV)
    # print(_transformPath--${propName}--${${propNameV}})
    _isTargetAttrPath(${propName} bIsVar)
    if(bIsVar)
        unset(bIsVar)

        set(ret)
        foreach(item ${${propNameV}})
            if (propName STREQUAL "SOURCES")
                # 处理目录会自动扫里面的代码
                _getSourceFullPath(fullPath ${item})
                foreach(fp ${fullPath})
                    if(EXISTS ${fp})
                        list(APPEND ret ${fp})
                    else()
                        error("${propName}:${${propName}} not valid!")
                    endif()
                endforeach()
                unset(fp)
            else()
                _getFullPath(fullPath ${item})
                if(EXISTS ${fullPath})
                    list(APPEND ret ${fullPath})
                elseif(NOT ${propName} IN_LIST __PATH_OR_NOT_ATTR_NAME)
                    error("${propName}:${${propName}} not valid!")
                else()
                    list(APPEND ret ${item})
                endif()
            endif()
        endforeach()

        set(${propNameV} ${ret})
        unset(item)
        unset(fullPath)
        unset(ret)
    endif()

    unset(bIsVar)
endmacro()

