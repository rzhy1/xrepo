package("expat")
    set_homepage("https://libexpat.github.io")
    set_description("expat is a stream-oriented XML parser library written in C.")
    set_license("MIT")
    
    set_urls("https://github.com/libexpat/libexpat/releases/download/R_$(version).tar.bz2", {
        version = function (version)
            return version:gsub("%.", "_") .. "/expat-" .. version
        end
    })

    add_versions("2.8.1", "f5833dd2e1cd7739ec9182804a1a29c4f0cc7c2f26b633d3a2188b7766a88ecb")

    -- 引入 cmake 作为底层构建工具依赖
    add_deps("cmake")

    on_load(function (package)
        if package:config("shared") ~= true then
            package:add("defines", "XML_STATIC")
        end
        if package:is_plat("windows", "mingw") then
            -- Expat 底层会调用这些随机数库，我们将其透传给 aria2c 防止最终链接失败
            package:add("syslinks", "advapi32", "bcrypt")
        end
    end)

    on_install(function (package)
        -- 核心：丢弃所有手动伪造宏和 xmake.lua 补丁的做法，
        -- 直接调用官方原汁原味的 CMakeLists.txt 进行完美构建！
        local configs = {
            "-DEXPAT_BUILD_EXAMPLES=OFF",
            "-DEXPAT_BUILD_TESTS=OFF",
            "-DEXPAT_BUILD_TOOLS=OFF",
            "-DEXPAT_BUILD_DOCS=OFF"
        }
        table.insert(configs, "-DEXPAT_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        
        -- 一键安装，CMake 会自动处理那些折磨人的环境宏
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XML_ParserCreate(NULL)", {includes = {"expat_external.h", "expat.h"}}))
    end)
