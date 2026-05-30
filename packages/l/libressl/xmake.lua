package("libressl")
    set_homepage("https://www.libressl.org")
    set_description("LibreSSL is a version of the TLS/crypto stack forked from OpenSSL in 2014, with goals of modernizing the codebase, improving security, and applying best practice development processes.")
    set_license("MIT")

    add_urls("https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(version).tar.gz")

    add_versions("4.3.2", "edf01aee24c65d69e6a9efcb9d44bcda682ff9d4f3bbbd95e794e1dfa90847b5")
    add_versions("4.2.0", "0f7dba44d7cb8df8d53f2cfbf1955254bc128e0089595f1aba2facfaee8408b2")

    add_configs("asm", {description = "Enable assembly optimizations", default = false, type = "boolean"})
    add_configs("openssldir", {description = "OpenSSL configuration directory", default = nil, type = "string"})
    add_configs("ca", {description = "Default CA file path", default = nil, type = "string"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "bcrypt")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    add_links("tls", "ssl", "crypto")

    on_install(function (package)
        local configs = {
            "-DLIBRESSL_APPS=OFF",
            "-DLIBRESSL_TESTS=OFF",
            "-DASM=" .. (package:config("asm") and "ON" or "OFF"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
        }
        if package:debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
        end
        if package:config("openssldir") then
            table.insert(configs, "-DOPENSSLDIR=" .. package:config("openssldir"))
        end
        if package:config("ca") then
            table.insert(configs, "-DDEFAULT_CA_FILE=" .. package:config("ca"))
        end
        
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tls_init", {includes = {"tls.h"}}))
        assert(package:has_cfuncs("SSL_CTX_new", {includes = {"openssl/ssl.h"}}))
    end)
