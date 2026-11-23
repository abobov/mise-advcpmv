local file = require("file")

--- Configures environment variables for the installed advcpmv
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#envkeys-hook
--- @param ctx {version: string, path: string, sdkInfo: table, main: SdkInfo, options: table} Context
--- @return table[] List of environment variable definitions
function PLUGIN:EnvKeys(ctx)
    return {
        {
            key = "ADVCPMV_HOME",
            value = ctx.path,
        },
        {
            key = "PATH",
            value = file.join_path(ctx.path, "bin"),
        },
    }
end
