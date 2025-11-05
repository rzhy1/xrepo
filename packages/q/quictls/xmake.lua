package("quictls")
    set_homepage("https://www.openssl.org/")
    set_description("TLS/SSL and crypto library")
    set_license("Apache-2.0")
    set_urls("https://github.com/openssl/openssl/releases/download/openssl-$(version)/openssl-$(version).tar.gz")

    -- 添加版本信息
    add_versions("3.6.0", "b6a5f44b7eb69e3fa35dbf15524405b44837a481d43d81daddde3ff21fcbb8e9")
    
    add_configs("installdir", {description = "installdir set", default = nil, type = "string"})
    add_links("ssl", "crypto")
    
    if is_plat("windows", "mingw") then
        add_syslinks("user32", "ws2_32", "advapi32", "crypt32")
    end

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "generate_xmake.lua"), "xmake.lua")
        os.cp(path.join(os.scriptdir(), "port", "scripts"), "scripts")
        local configs = {}
        if package:config('installdir') then
            table.insert(configs, "--installdir="..package:config('installdir'))
        end
        import("package.tools.xmake").install(package, configs)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_CTX_new", {includes = {"openssl/ssl.h"}}))
    end)
