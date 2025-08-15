package("gettext-tools")
    set_kind("binary")
    set_homepage("https://github.com/vslavik/gettext-tools-windows")
    set_description("GNU gettext tools compiled binaries for Windows")
    set_license("GPL-3.0")
    set_urls("https://github.com/vslavik/gettext-tools-windows/releases/download/v$(version)/gettext-tools-windows-$(version).zip")
              https://github.com/vslavik/gettext-tools-windows/releases/download/v0.26/gettext-tools-windows-0.26.zip

    --insert version
    add_versions("0.26", "31b0d12d16f4e6655bb4922332f931d69a2e105d17c5e2ebadc7a5b0735d37ff")
    on_install(function (package)
        os.cp("*", package:installdir())
    end)
