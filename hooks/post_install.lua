local file = require("file")

--- Performs additional setup after installation
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#postinstall-hook
--- @param ctx {rootPath: string, runtimeVersion: string, sdkInfo: table, options: table} Context
function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path
    local version = sdkInfo.version -- e.g. "1.0-9.12"
    local advcpmv = require("advcpmv")

    -- Parse "patchver-coreutilsver"
    local patchver, coreutils_ver = advcpmv.parse_version(version)
    if not coreutils_ver then
        error(advcpmv.invalid_version_error(version))
    end

    local bin_dir = file.join_path(path, "bin")

    -- Create bin directory
    os.execute("mkdir -p " .. bin_dir)

    -- Download install.sh from the advcpmv repository and run it to
    -- download coreutils, apply the advcpmv patch, configure, and build.
    -- The script produces advcp and advmv in the install path.
    local http = require("http")
    local install_script_url = advcpmv.INSTALL_SCRIPT_URL
    local install_script = file.join_path(path, "install.sh")

    local ok, err = pcall(function()
        http.download_file({ url = install_script_url }, install_script)
    end)
    if not ok then
        error("Failed to download install.sh from " .. install_script_url .. ": " .. tostring(err))
    end

    -- Run install.sh with output captured to a log file so we can
    -- include the actual error message if it fails.
    local install_log = file.join_path(path, "install.log")
    local result = os.execute(
        "cd "
            .. path
            .. " && sh "
            .. install_script
            .. " "
            .. patchver
            .. " "
            .. coreutils_ver
            .. " > "
            .. install_log
            .. " 2>&1"
    )
    if result ~= 0 then
        local log_contents = ""
        local f = io.open(install_log, "r")
        if f then
            log_contents = f:read("*a")
            f:close()
        end
        error("install.sh failed for advcpmv " .. version .. ":\n" .. log_contents)
    end

    -- Clean up the install log on success
    os.execute("rm -f " .. install_log)

    -- Create symlinks from bin/ to the built binaries in the install root.
    -- This keeps advcp/advmv/install.sh in the root while bin/ provides
    -- the PATH-accessible entry points.
    -- Fall back to copying if symlinks are not supported on the filesystem.
    for _, bin in ipairs({ "advcp", "advmv" }) do
        if os.execute("ln -sf " .. file.join_path("..", bin) .. " " .. file.join_path(bin_dir, bin)) ~= 0 then
            os.execute("cp " .. file.join_path(path, bin) .. " " .. file.join_path(bin_dir, bin))
        end
    end

    -- Optional symlinks: cpg -> advcp, mvg -> advmv
    -- Controlled by the install_cpg_mvg option (mise.toml). Default: disabled.
    local install_cpg_mvg = false
    if ctx.options and ctx.options.install_cpg_mvg ~= nil then
        install_cpg_mvg = ctx.options.install_cpg_mvg
    end

    if install_cpg_mvg then
        local ok_sym, err_sym = pcall(function()
            file.symlink("../advcp", file.join_path(bin_dir, "cpg"))
            file.symlink("../advmv", file.join_path(bin_dir, "mvg"))
        end)
        if not ok_sym then
            -- Fall back to copying when symlinks are unsupported
            os.execute("cp " .. file.join_path(path, "advcp") .. " " .. file.join_path(bin_dir, "cpg"))
            os.execute("cp " .. file.join_path(path, "advmv") .. " " .. file.join_path(bin_dir, "mvg"))
        end
    end
end
