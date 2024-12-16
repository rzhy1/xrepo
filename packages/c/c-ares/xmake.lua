package("c-ares")
    set_homepage("https://c-ares.org")
    set_description("A C library for asynchronous DNS requests")
    set_license("MIT")
    set_urls("https://github.com/c-ares/c-ares/releases/download/v$(version)/c-ares-$(version).tar.gz", {
        version = function()
            import("net.http")
            import("core.base.semver")
            local response = http.download_content("https://api.github.com/repos/c-ares/c-ares/releases/latest")
            local latest = response:match('"tag_name"%s*:%s*"v([%d%.]+)"')
            assert(latest, "Failed to fetch latest version from GitHub API.")
            return latest
        end
    })

    -- 使用一个固定的动态哈希值解析函数
    add_versions("dynamic", function(version)
        import("net.http")
        import("lib.detect.find_tool")
        local sha256sum = assert(find_tool("sha256sum"), "sha256sum is required to calculate hash!")
        local tmpfile = os.tmpfile() .. ".tar.gz"
        local url = string.format("https://github.com/c-ares/c-ares/releases/download/v%s/c-ares-%s.tar.gz", version, version)
        http.download(url, tmpfile)
        local hash = os.iorunv(sha256sum.program, {tmpfile})
        os.rm(tmpfile)
        return hash:split("%s")[1]
    end)

    on_load(function (package)
        if package:is_plat("windows", "mingw") and package:config("shared") ~= true then
            package:add("defines", "CARES_STATICLIB")
        end
    end)

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port/*.lua"), "./")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ares_library_initialized", {includes = "ares.h"}))
    end)
