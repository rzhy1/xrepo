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

    -- 动态获取最新版本的哈希值
    add_versions("dynamic", function (version)
        import("lib.detect.find_tool")
        import("net.http")
        local download_url = string.format("https://github.com/c-ares/c-ares/releases/download/v%s/c-ares-%s.tar.gz", version, version)
        local tmpfile = os.tmpfile() .. ".tar.gz"
        http.download(download_url, tmpfile)
        local sha256sum = assert(find_tool("sha256sum"), "sha256sum is required to calculate the hash!")
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
        local transforme_configfile = function(input, output)
            output = output or input
            local lines = io.readfile(input):gsub("@([%w_]+)@", "${%1}"):split("\n")
            local out = io.open(output, 'wb')
            for _, line in ipairs(lines) do
                if line:startswith("#cmakedefine") then
                    local name = line:split("%s+")[2]
                    line = "${define " .. name .. "}"
                end
                out:write(line)
                out:write("\n")
            end
            out:close()
        end
        transforme_configfile("include/ares_build.h.cmake", "cmake/ares_build.h.in")
        transforme_configfile("src/lib/ares_config.h.cmake", "cmake/ares_config.h.in")
        os.cp(path.join(os.scriptdir(), "port/*.lua"), "./")
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ares_library_initialized", {includes = {"ares.h"}}))
    end)
