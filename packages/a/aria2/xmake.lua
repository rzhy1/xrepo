local common_patches = {
    {"patches/socketcore-logger-fix.patch", "6fdfde0c07bd096168167690d0d8405b5937f23dfbb641c5ace73fe51f5ecfe1"},
    {"patches/android-lock-fix.patch", "97dd927493d53f36554f8dcca5c4fc03d51838e5ff87406e76f6ea8f8e29dcdb"},
    -- https://github.com/aria2/aria2/pull/2268
    {"patches/pr-2268.patch", "0d193712bdddcfeb200c92387cb6e04fd437fdc26a557a135b6a011762a36d31"},
    -- https://github.com/aria2/aria2/pull/2239
    {"patches/pr-2239.patch", "dfa67b5e31cbaacbc99e4ccadbddf594fcaeeae3efd31d238e3d8c1bff4e4c25"},
    -- https://github.com/aria2/aria2/pull/2209
    {"patches/pr-2209.patch", "89e78c6b3b9e8e04fd3b5e084cb0381de2561af899d2301cfe41ff7cec5f9e0b"},
    -- https://github.com/myfreeer/aria2-build-msys2/blob/master/aria2-0001-options-change-default-path-to-current-dir.patch
    {"patches/aria2-0001-options-change-default-path-to-current-dir.patch", "4f8a7cc119a2ae226d3ac78fc801a3004d237f5450f90476131276408bcb3528"},
    {"patches/limit-fix.patch", "a1c04bf0f2132708ab6f213b135d606ed3f21e1889440a3eecf261055fba7fea"},
}

package("aria2")
    set_homepage("https://aria2.github.io")
    set_description("aria2 is a lightweight multi-protocol & multi-source, cross platform download utility operated in command-line. It supports HTTP/HTTPS, FTP, SFTP, BitTorrent and Metalink.")
    set_license("GPL-2.0")
    set_urls("https://github.com/aria2/aria2/releases/download/release-$(version)/aria2-$(version).tar.xz")

    -- 只保留最新版本
    add_versions("1.37.0", "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b")

    add_configs("uv", {description = "build use libuv", default = false, type = "boolean"})
    
    -- 添加补丁
    for _, v in ipairs(common_patches) do
        add_patches("1.37.0", path.join(os.scriptdir(), v[1]), v[2])
    end

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(os.scriptdir(), "port", "config.h.in"), "config.h.in")
        local configs = {}
        if package:config("uv") == true then
            configs["uv"] = "y"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    -- on_test(function (package)
    --     assert(package:has_cfuncs("xxx", {includes = {"xx.h"}}))
    -- end)
