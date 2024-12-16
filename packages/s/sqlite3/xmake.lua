package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")

    -- 动态设置 URL 和版本
    on_source(function (package)
        -- Step 1: 获取最新版本号
        local index_html = os.iorun("curl -s https://www.sqlite.org/index.html")
        assert(index_html, "Failed to fetch SQLite index page!")
        local latest_version = index_html:match(">Version ([%d%.]+)<")
        assert(latest_version, "Failed to extract latest SQLite version!")

        -- Step 2: 获取下载页面
        local download_page = os.iorun("curl -s https://www.sqlite.org/download.html")
        assert(download_page, "Failed to fetch SQLite download page!")

        -- 提取 CSV 数据和 tarball URL
        local csv_data = download_page:match("Download product data for scripts to read.-(autoconf.*%.tar%.gz)")
        assert(csv_data, "Failed to extract download URL data!")
        local tarball_url = csv_data:match("autoconf.*%.tar%.gz")
        assert(tarball_url, "Failed to extract tarball URL!")

        -- 构造最新的 tarball 下载地址
        local latest_url = "https://www.sqlite.org/" .. tarball_url

        -- 设置 URL 和版本
        package:set("urls", latest_url)
        package:add("versions", latest_version, "SKIP_CHECKSUM")
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

    -- 安装逻辑
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

    -- 测试逻辑
    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_libversion_number()", {includes = "sqlite3.h"}))
    end)
