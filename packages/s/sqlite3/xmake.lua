package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")

    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = tostring(version):match("+(%d+)%.%d+$")
        version_str = version:gsub(year, ""):gsub("[.+]", "")
        if #version_str < 7 then
            version_str = version_str .. "00"
        end
        return year .. "/sqlite-autoconf-" .. version_str .. ".tar.gz"
    end})

    --insert version

    add_versions("3.50.0+2025.400", "a3db587a1b92ee5ddac2f66b3edb41b26f9c867275782d46c3a088977d6a5b18")

    add_configs("explain_comments", { description = "Inserts comment text into the output of EXPLAIN.", default = true, type = "boolean"})
    add_configs("dbpage_vtab",      { description = "Enable the SQLITE_DBPAGE virtual table.", default = true, type = "boolean"})
    add_configs("stmt_vtab",        { description = "Enable the SQLITE_STMT virtual table logic.", default = true, type = "boolean"})
    add_configs("dbstat_vtab",      { description = "Enable the dbstat virtual table.", default = true, type = "boolean"})
    add_configs("math_functions",   { description = "Enable the built-in SQL math functions.", default = true, type = "boolean"})
    add_configs("rtree",            { description = "Enable R-Tree.", default = false, type = "boolean"})
    add_configs("safe_mode",        { description = "Use thread safe mode in 0 (single thread) | 1 (serialize) | 2 (mutli thread).", default = "1", type = "string", values = {"0", "1", "2"}})
    add_configs("cli",              { description = "Build the sqlite3 command line shell.", default = false, type = "boolean"})

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
