# 文件编译存在警告则视为报错
function(set_compile_warnning_as_werror source_list)
    foreach(src IN LISTS source_list)
        if("${src}" MATCHES "\\.(cpp|mm|c|m)\$")
            set_source_files_properties("${src}" PROPERTIES
                COMPILE_FLAGS "/WX"
            )
        endif()
    endforeach()
endfunction()

