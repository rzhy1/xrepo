import("net.http")
import("core.base.hashset")

package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")

    on_load(function (package)
        -- 动态解析最新版本信息
        local sqlite_url = "https://sqlite.org/download.html"
        local html = http.get(sqlite_url)
        assert(html, "Failed to fetch SQLite download page!")

        -- 正则匹配最新版本号和 tar.gz 文件链接
        local latest_version, latest_url = html:match('href="([^\"]*sqlite%-autoconf%-(%d+).tar.gz)"')
        assert(latest_version and latest_url, "Failed to find latest SQLite version!")

        -- 解析版本号
        latest_version = latest_version:sub(1, 1) .. "." .. latest_version:sub(2, 2) .. "." .. latest_version:sub(3)
        local download_url = "https://sqlite.org/" .. os.date("%Y") .. "/" .. latest_url

        -- 手动计算文件的哈希值（假设用 SHA256）
        local hash = http.download(download_url, {cachedir = os.tmpdir()})
        assert(hash, "Failed to download SQLite tar.gz for hash computation!")
        local hash_value = hashset.sha256(hash)

        -- 更新包信息
        package:set("urls", download_url)
        package:add("versions", latest_version, hash_value)
    end)

    -- 配置选项
    add_configs("explain_comments", { description = "Inserts comment text into the output of EXPLAIN.", default = true, type = "boolean"})
    add_configs("dbpage_vtab",      { description = "Enable the SQLITE_DBPAGE virtual table.", default = true, type = "boolean"})
    add_configs("stmt_vtab",        { description = "Enable the SQLITE_STMT virtual table logic.", default = true, type = "boolean"})
    add_configs("dbstat_vtab",      { description = "Enable the dbstat virtual table.", default = true, type = "boolean"})
    add_configs("math_functions",   { description = "Enable the built-in SQL math functions.", default = true, type = "boolean"})
    add_configs("rtree",            { description = "Enable R-Tree.", default = false, type = "boolean"})
    add_configs("safe_mode",        { description = "Use thread safe mode in 0 (single thread) | 1 (serialize) | 2 (mutli thread).", default = "1", type = "string", values = {"0", "1", "2"}})
    add_configs("cli",              { description = "Build the sqlite3 command line shell.", default = false, type = "boolean"})

    -- 安装步骤
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

    -- 测试步骤
    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_libversion_number()", {includes = "sqlite3.h"}))
    end)
