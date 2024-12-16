package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")

    -- 固定下载地址
    set_urls("https://sqlite.org/2024/sqlite-autoconf-3470200.tar.gz", {verify = false})

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        for opt, value in pairs(package:configs()) do
            if not package:extraconf("configs", opt, "builtin") then
                configs[opt] = value
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_libversion_number()", {includes = "sqlite3.h"}))
    end)
