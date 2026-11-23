-- metadata.lua
-- Plugin metadata and configuration
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#metadata-lua

PLUGIN = { -- luacheck: ignore
    -- Required: Plugin metadata name
    name = "advcpmv",

    -- Required: Plugin metadata version
    version = "1.0.0",

    -- Optional: Plugin description
    description = "A mise tool plugin for advcpmv (Advanced Copy for GNU cp/mv)",

    -- Optional: Plugin author
    author = "abobov",

    -- Optional: License name
    license = "MIT",

    -- Optional: Plugin homepage
    homepage = "https://github.com/abobov/mise-advcpmv",

    -- Optional: System dependencies needed to build from source
    systemDependencies = {
        { bin = "curl" },
        { bin = "patch" },
        { bin = "gcc" },
        { bin = "makeinfo" },
        { bin = "make" },
        { bin = "tar" },
        { bin = "xz" },
    },
}
