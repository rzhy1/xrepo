if is_plat("windows") then
    add_syslinks("ws2_32", "ntdll", "bcrypt")
end

on_install(function (package)
    import("package.tools.cmake").install(package, {
        "-DLIBRESSL_APPS=OFF",
        "-DLIBRESSL_TESTS=OFF"
    })
end)
