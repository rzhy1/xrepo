package("nonstd.string-view")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/string-view-lite")
    set_description("string_view lite - A C++17-like string_view for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")
    set_urls("https://github.com/martinmoene/string-view-lite/archive/refs/tags/v$(version).tar.gz")

    --insert version
    add_versions("1.8.2", "62852addccb3b73b72030c6afd130e8b63f9b2a00b032b0af4048b0cc6b49f82")
    on_install(function (package)
        os.cp("include/nonstd", package:installdir("include").."/")
    end)

    -- on_test(function (package)
    --     assert(package:has_cfuncs("xxx", {includes = {"xx.h"}}))
    -- end)

