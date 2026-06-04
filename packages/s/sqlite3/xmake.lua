package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("Public Domain")
    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local major, minor, patch, year, suffix = tostring(version):match("(%d+)%.(%d+)%.?(%d*)%+(%d+)%.?(%d*)") 
        if major and minor and year then
            local zz_uu
            if suffix and suffix ~= "" then
                zz_uu = string.format("%04d", tonumber(suffix))
            else
                local patch_num = (patch and patch ~= "") and tonumber(patch) or 0
                zz_uu = string.format("%04d", patch_num * 100)
            end
            local version_str = string.format("%s%02d%s", major, tonumber(minor), zz_uu)
            return year .. "/sqlite-autoconf-" .. version_str .. ".tar.gz"
        else
            error("Unsupported version format: " .. tostring(version) .. ". Expected pattern: X.Y.Z+YYYY.REV")
        end
    end})

    add_versions("3.53.0+2026.200", "588ad51949419a56ebe81fe56193d510c559eb94c9a57748387860b5d3069316")

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
