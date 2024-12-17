package("c-ares")
 set_homepage("https://c-ares.org")
 set_description("A C library for asynchronous DNS requests")
 set_license("MIT")

 local version = nil

 on_load(function (package) 
     if package:is_plat("windows", "mingw") and package:config("shared") ~= true then
         package:add("defines", "CARES_STATICLIB")
     end
 end)

  on_install(function (package)
        local function get_latest_version()
            local retry = function(cmd)
                local output, code = os.runv(cmd)
                if code == 0 then
                  return output
                end
                return nil
              end
              local output = retry{'curl', '-s', "https://api.github.com/repos/c-ares/c-ares/releases/latest"}
              if not output then
                 return nil
             end
              local tag_name = output:match('"tag_name":"([^"]*)"')
              if tag_name then
                  return tag_name:gsub("v", "")
              end
              return nil
         end
 
     -- 动态获取版本号
     version = get_latest_version()
     if not version then
       print("Failed to get the latest version of c-ares, using default version 1.20.1")
       version = "1.20.1"
     end
      set_version(version)
      set_urls("https://github.com/c-ares/c-ares/releases/download/v$(version)/c-ares-$(version).tar.gz")
    
      local transforme_configfile = function (input, output) 
         output = output or input
         local lines = io.readfile(input):gsub("@([%w_]+)@", "${%1}"):split("\n")
         local out = io.open(output, 'wb')
         for _, line in ipairs(lines) do
             if line:startswith("#cmakedefine") then
                 local name = line:split("%s+")[2]
                 line = "${define "..name.."}"
             end
             out:write(line)
             out:write("\n")
         end
         out:close()
      end
      transforme_configfile("include/ares_build.h.cmake", "cmake/ares_build.h.in")
      transforme_configfile("src/lib/ares_config.h.cmake", "cmake/ares_config.h.in")
      os.cp(path.join(os.scriptdir(), "port/*.lua"), "./")
      local configs = {}
      import("package.tools.xmake").install(package, configs)
  end)

 on_test(function (package)
     assert(package:has_cfuncs("ares_library_initialized", {includes = {"ares.h"}, includepaths = {"include"}}))
 end)
