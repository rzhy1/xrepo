package("sqlite3")
    set_homepage("https://sqlite.org/index.html")
    set_description("SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
    set_license("MIT")
    
    local version = nil
    local download_url = nil
     
    local function get_download_url(version)
       return "https://www.sqlite.org/2024/sqlite-autoconf-" .. version:gsub("[.+]", "") .. "00.tar.gz"
    end

    on_install(function (package)
        local function get_sqlite_info()
            local retry = function(cmd)
              local output, code = os.runv(cmd)
              if code == 0 then
                return output
              end
              return nil
            end
            local index_page = retry{"curl", "-s", "https://www.sqlite.org/index.html"}
            if not index_page then
              return nil, nil
            end
            
            local version = index_page:match(">Version ([0-9.]+)<")
            
            local download_page = retry{"curl", "-s", "https://www.sqlite.org/download.html"}
            if not download_page then
              return nil, nil
            end
            
            local csv_data = download_page:match("Download product data for scripts to read(.*)-->")
            if not csv_data then
               return nil,nil
            end
            local tarball_url = csv_data:match("autoconf.*%.tar%.gz")
            if not tarball_url then
               return nil, nil
            end
            local download_url = "https://www.sqlite.org/" .. tarball_url
            
            return version, download_url
          end
          
        version, download_url = get_sqlite_info()
        if not version then
            print("Failed to get the latest version of sqlite3, using default version 3.47.0")
           version = "3.47.0"
           download_url = "https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz"
        end
        set_version(version)
        set_urls(download_url, {version = function (version)
          local version_str = version:gsub("[.+]", "")
          if #version_str < 7 then
              version_str = version_str .. "00"
          end
          return version_str
        end})
        
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
