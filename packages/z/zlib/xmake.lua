package("zlib")
    set_homepage("https://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")
    set_license("zlib")
    set_urls("https://github.com/madler/zlib/releases/download/v$(version)/zlib-$(version).tar.gz")

    --insert version
    add_versions("1.3.2", "bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16")

    add_includedirs("include")
    add_includedirs("include/zlib")
    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gzopen(NULL, NULL)", {includes = "zlib/zlib.h"}))
    end)
