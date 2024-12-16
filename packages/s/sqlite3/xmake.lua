package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")

    -- 动态设置 URL 和版本
    on_load(function (package)
        import("net.http")  -- 确保在需要的地方加载模块

        -- Step 1: 获取 SQLite 最新版本号
        local index_html = http.get("https://www.sqlite.org/index.html")
        assert(index_html, "Failed to fetch SQLite index page!")
        local latest_version = index_html:match(">Version ([%d%.]+)<")
        assert(latest_version, "Failed to extract latest SQLite version!")

        -- Step 2: 获取下载页面内容
        local download_page = http.get("https://www.sqlite.org/download.html")
        assert(download_page, "Failed to fetch SQLite download page!")

        -- Step 3: 提取 CSV 数据
        local csv_data = download_page:match("Download product data for scripts to read.-(autoconf.*%.tar%.gz)")
        assert(csv_data, "Failed to extract download URL data!")

        -- Step 4: 构造最新的 tarball 下载地址
        local tarball_url = csv_data:match("autoconf.*%.tar%.gz")
        assert(tarball_url, "Failed to extract tarball URL!")
        local latest_url = "https://www.sqlite.org/" .. tarball_url

        -- Step 5: 更新包信息
        package:set("urls", latest_url)
        package:add("versions", latest_version, "SKIP_CHECKSUM") -- 默认不校验哈希
    end)

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
