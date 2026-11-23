--- Returns a list of available versions for advcpmv
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#available-hook
--- @param ctx {args: string[]} Context (args = user arguments)
--- @return table[] List of available versions
function PLUGIN:Available(ctx)
    local http = require("http")
    local json = require("json")
    local advcpmv = require("advcpmv")

    -- advcpmv patch files are hosted in the jarun/advcpmv repository on master.
    -- List the repository contents and extract versions from patch filenames
    -- like advcpmv-1.0-9.12.patch -> 1.0-9.12
    local resp, err = http.get({ url = advcpmv.API_URL })
    if err ~= nil then
        error("Failed to fetch advcpmv versions: " .. err)
    end
    if resp.status_code ~= 200 then
        error("GitHub API returned status " .. resp.status_code .. ": " .. resp.body)
    end

    local contents = json.decode(resp.body)
    local versions = {}

    for _, item in ipairs(contents) do
        if item.type == "file" then
            local name = item.name
            -- Filename format: advcpmv-<patchver>-<coreutilsver>.patch
            local patchver, coreutils_ver = name:match(advcpmv.PATCH_FILENAME_PATTERN)
            if patchver and coreutils_ver then
                local raw_version = patchver .. "-" .. coreutils_ver
                table.insert(versions, raw_version)
            end
        end
    end

    if #versions == 0 then
        error("No advcpmv patch files found in " .. advcpmv.GITHUB_REPO .. " repository")
    end

    -- Sort versions descending (newest first)
    advcpmv.sort_versions_desc(versions)

    local result = {}
    for _, version in ipairs(versions) do
        table.insert(result, { version = version })
    end
    return result
end
