--- Returns download information for a specific advcpmv version
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook
--- @param ctx {args: string[], version: string} Context
--- @return table Version and download information
function PLUGIN:PreInstall(ctx)
    local version = ctx.version -- e.g. "1.0-9.12"
    local advcpmv = require("advcpmv")

    -- advcpmv builds GNU coreutils from source with gcc; this only works
    -- reliably on Linux. Reject other platforms early with a clear message.
    if RUNTIME.osType:lower() ~= "linux" then
        error(
            "advcpmv is Linux-only. Building from source requires gcc, "
                .. "patch, make, and makeinfo which are not supported on "
                .. RUNTIME.osType
                .. "."
        )
    end

    -- Parse "patchver-coreutilsver" -> coreutils version is after the last hyphen
    local patchver, coreutils_ver = advcpmv.parse_version(version)
    if not coreutils_ver then
        error(advcpmv.invalid_version_error(version))
    end

    -- Fast-fail if any required build tool is missing, so the user gets a
    -- clear message before any download or compile step runs.
    local missing = advcpmv.missing_system_bins()
    if #missing > 0 then
        local pkgs = table.concat(missing, " ")
        error(
            "advcpmv build requires missing system tools: "
                .. table.concat(missing, ", ")
                .. "\nInstall them first (e.g. sudo apt install "
                .. pkgs
                .. "), then run: mise install advcpmv@"
                .. version
        )
    end

    -- No URL returned here: install.sh (called from post_install)
    -- handles downloading coreutils, applying the patch, and building.
    -- mise skips the download phase and proceeds directly to post_install.
    return {
        version = version,
        note = "Building advcpmv " .. version .. " from source via install.sh",
    }
end
