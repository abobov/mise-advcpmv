--- Shared constants and helpers for the advcpmv mise plugin
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#lib

local M = {}

-- Upstream repository that hosts advcpmv patches and install.sh
M.GITHUB_REPO = "jarun/advcpmv"

-- GitHub contents API URL for listing patch files
M.API_URL = "https://api.github.com/repos/" .. M.GITHUB_REPO .. "/contents/"

-- Raw URL for the install.sh build script
M.INSTALL_SCRIPT_URL = "https://raw.githubusercontent.com/" .. M.GITHUB_REPO .. "/master/install.sh"

-- Patch filename pattern: advcpmv-<patchver>-<coreutilsver>.patch
M.PATCH_FILENAME_PATTERN = "^advcpmv%-(.-)%-(.+)%.patch$"

-- Version string pattern: patchver-coreutilsver (e.g. 1.0-9.12)
M.VERSION_PATTERN = "^(.+)%-(.+)$"

--- Check that every system binary declared in metadata.lua systemDependencies
-- exists on PATH. metadata.lua is the single source of truth for required tools.
--- @return string[] missing binary names (empty when all are present)
function M.missing_system_bins()
    local missing = {}
    local deps = PLUGIN and PLUGIN.systemDependencies or {}
    for _, dep in ipairs(deps) do
        local bin = dep.bin
        if bin and os.execute("command -v " .. bin .. " >/dev/null 2>&1") ~= 0 then
            table.insert(missing, bin)
        end
    end
    return missing
end

--- Parse a version string "patchver-coreutilsver" into its components.
--- Handles optional "v-" prefix that mise may add.
--- @param version string e.g. "1.0-9.12" or "v-1.0-9.12"
--- @return string? patchver e.g. "1.0"
--- @return string? coreutils_ver e.g. "9.12"
function M.parse_version(version)
    return version:match(M.VERSION_PATTERN)
end

--- Return an error message for an invalid version string.
--- @param version string The invalid version string
--- @return string error message
function M.invalid_version_error(version)
    return "Invalid advcpmv version format: " .. version .. " (expected patchver-coreutilsver, e.g. 1.0-9.12)"
end

--- Compare two coreutils version strings numerically.
--- e.g. "9.12" > "9.9" (string comparison would say the opposite).
--- @param a string e.g. "9.12"
--- @param b string e.g. "9.9"
--- @return boolean true if a is newer than b
local function coreutils_newer(a, b)
    local aa = { a:match("^(%d+)%.(%d+)$") }
    local bb = { b:match("^(%d+)%.(%d+)$") }
    if #aa == 0 or #bb == 0 then
        return a > b
    end
    local a1, a2 = tonumber(aa[1]), tonumber(aa[2])
    local b1, b2 = tonumber(bb[1]), tonumber(bb[2])
    if a1 ~= b1 then
        return a1 > b1
    end
    return a2 > b2
end

--- Sort version strings descending (newest first).
--- Compares by patchver then coreutils_ver numerically.
--- @param versions string[] e.g. {"1.0-9.12", "0.8-8.32"}
--- @return string[] sorted versions
function M.sort_versions_desc(versions)
    table.sort(versions, function(a, b)
        -- Match the LAST hyphen as separator (greedy .+ for patchver)
        local ap, ac = a:match("^(.+)%-(.+)$")
        local bp, bc = b:match("^(.+)%-(.+)$")
        if ap ~= bp then
            return ap > bp
        end
        return coreutils_newer(ac, bc)
    end)
    return versions
end

return M
