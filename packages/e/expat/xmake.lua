package("expat")
    set_homepage("https://libexpat.github.io")
    set_description("expat is a stream-oriented XML parser library written in C.")
    set_license("MIT")
    set_urls("https://github.com/libexpat/libexpat/releases/download/R_$(version).tar.bz2", {version = function (version)
        return version:gsub("%.", "_") .. "/expat-" .. version
    end})

    add_versions("2.8.0", "586494499ac3ad46d87f3beda7b1f770c1c8026a9b60e151593f8b29089a52ca")

    on_load(function (package)
        if package:config("shared") ~= true then
            package:add("defines", "XML_STATIC")
        end
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "advapi32", "bcrypt")
        end
    end)

    on_install(function (package)
        -- 1. 拷贝自带的构建脚本
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        
        -- 2. 【真正的解药】拦截并修改构建脚本
        -- 将官方遗留脚本中导致报错的 "HAVE_RAND_S" 强行替换为无害的 "HAVE_BCRYPT"
        local xmake_lua_content = io.readfile("xmake.lua")
        xmake_lua_content = xmake_lua_content:gsub('"HAVE_RAND_S"', '"HAVE_BCRYPT"')
        
        -- 确保链接上 Expat 2.8.0 所需的 bcrypt 库
        xmake_lua_content = xmake_lua_content .. '\n\ntarget("expat")\nadd_syslinks("advapi32", "bcrypt")\n'
        io.writefile("xmake.lua", xmake_lua_content)

        -- 3. 生成最纯净的头文件（删除了之前加的那些补丁）
        local version = package:version_str()
        local config_h_in = [[
${define _HOST_BIGENDIAN}

#if _HOST_BIGENDIAN == 1
#define BYTEORDER 4321
#else
#define BYTEORDER 1234
#endif

#define XML_CONTEXT_BYTES 1024
#define XML_DTD 1
#define XML_NS 1
#define XML_GE 1
#define PACKAGE "expat"
#define PACKAGE_BUGREPORT "expat-bugs@libexpat.org"
#define PACKAGE_NAME "expat"
#define PACKAGE_STRING "expat @VERSION@"
#define PACKAGE_TARNAME "expat"
#define PACKAGE_URL ""
#define PACKAGE_VERSION "@VERSION@"
#define STDC_HEADERS 1
#define VERSION "@VERSION@"

#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

#if !defined(_WIN32)
#define XML_DEV_URANDOM 1
#endif

${define HAVE_ARC4RANDOM}
${define HAVE_ARC4RANDOM_BUF}
${define HAVE_GETPAGESIZE}
${define HAVE_GETRANDOM}
${define HAVE_MMAP}
${define HAVE_DLFCN_H}
${define HAVE_FCNTL_H}
${define HAVE_INTTYPES_H}
${define HAVE_MEMORY_H}
${define HAVE_STDINT_H}
${define HAVE_STDLIB_H}
${define HAVE_STRINGS_H}
${define HAVE_STRING_H}
${define HAVE_SYS_PARAM_H}
${define HAVE_SYS_STAT_H}
${define HAVE_SYS_TYPES_H}
${define HAVE_UNISTD_H}
]]
        
        config_h_in = config_h_in:gsub("@VERSION@", version)
        io.writefile("expat_config.h.in", config_h_in, {encoding = "binary"})

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XML_ParserCreate(NULL)", {includes = {"expat_external.h", "expat.h"}}))
    end)
