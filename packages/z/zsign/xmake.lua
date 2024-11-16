local function getVersion(version)
    local versions ={
        ["2024.09.10-alpha"] = "archive/3c23b6192364c12200ba5950ec363d6877f8c920.tar.gz",
        --insert getVersion
    }
    return versions[tostring(version)]
end
package("zsign")
    set_kind("binary")
    set_homepage("https://github.com/zhlynn/zsign")
    set_description("Maybe it is the most quickly codesign alternative for iOS12+, cross-platform ( macOS, Linux , Windows ), more features.")
    set_license("BSD-3-Clause")
    set_urls("https://github.com/zhlynn/zsign/$(version)", {
        version = getVersion
    })

    --insert version
    add_versions("2024.09.10-alpha", "6f60d78cd3c93fef43d02cdc918c674ba62c1a2da7e59b160d830172a3a3c074")
    add_patches("2024.09.10-alpha", path.join(os.scriptdir(), "patches/libressl-1.patch"), "39bd8a723a03dc5a976b47af0cc61aece08a0065322a6457fed1b0c35f8da33a")
    on_install(function (package)
        io.writefile("xmake.lua", [[
add_rules("mode.debug", "mode.release")

if is_plat("windows") then
    add_cflags("/TC", {tools = {"clang_cl", "cl"}})
    add_cxxflags("/EHsc", {tools = {"clang_cl", "cl"}})
    add_defines("UNICODE", "_UNICODE")
end
add_requires("libressl")
target("zsign")
    set_kind("binary")
    add_files("*.cpp", "common/*.cpp")
    add_packages("libressl")
    set_languages("c99", "c++14")
]], {encoding = "binary"})
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    -- on_test(function (package)
    --     assert(package:has_cfuncs("xxx", {includes = {"xx.h"}}))
    -- end)