# mise-advcpmv

A [mise](https://mise.jdx.dev) tool plugin for [advcpmv](https://github.com/jarun/advcpmv) — Advanced Copy for GNU `cp` and `mv`, which adds a progress bar.

## Installation

```bash
mise plugin add advcpmv https://github.com/abobov/mise-advcpmv.git
mise use advcpmv@latest
```

Install the plugin from the repository (no version pin — mise always runs the latest plugin code), then install the advcpmv tool. Use `@latest` to always track the newest upstream release, or pin a specific version for reproducibility:

```bash
mise use advcpmv@1.0-9.12
```

List all available versions:

```bash
mise ls-remote advcpmv
```

## Finding a version

advcpmv versions are expressed as `patchver-coreutilsver` (e.g. `1.0-9.12`).
Versions are fetched live from the upstream [jarun/advcpmv](https://github.com/jarun/advcpmv)
repository, so the list is always up to date.

## Commands

The plugin builds two binaries from patched GNU coreutils:

| Command | Description |
|---------|-------------|
| `advcp` | `cp` with progress bar (`-g`/`--progress-bar`) |
| `advmv` | `mv` with progress bar (`-g`/`--progress-bar`) |

### Optional `cpg` / `mvg` symlinks

To also create `cpg` → `advcp` and `mvg` → `advmv` symlinks,
set `install_cpg_mvg` to `true`:

```toml
[tools]
advcpmv = { version = "1.0-9.12", options = { install_cpg_mvg = true } }
```

These short aliases are useful with file managers like
[nnn](https://github.com/jarun/nnn) (maintained by the same author
as advcpmv) that can be configured to run external copy/move commands.

## Platform Support

advcpmv is **Linux-only**. It builds GNU coreutils from source using `gcc`, `patch`, `make`, and `makeinfo`, which are not reliably available on other platforms. `mise install advcpmv` will fail with a clear error on macOS or Windows.

## How it works

advcpmv is distributed as a source patch for GNU coreutils, not as a pre-built binary. The plugin:

1. Downloads the GNU coreutils source tarball from ftp.gnu.org
2. Applies the advcpmv patch from jarun/advcpmv
3. Runs `./configure && make`
4. Installs `advcp` and `advmv` into the mise install `bin/` directory
5. Optionally creates `cpg` and `mvg` symlinks

Build dependencies (`patch`, `gcc`, `makeinfo`, `make`) must be available on your system.

## Development

```bash
# Link the local plugin for development
mise plugin link --force advcpmv .

# Install and test a version
mise install advcpmv@1.0-9.12

# Run the test task
mise run test

# Lint
mise run lint

# Full CI
mise run ci
```

## License

The mise-advcpmv plugin is licensed under the **MIT License**.

Note: advcpmv (the upstream tool) and the GNU coreutils it patches are
licensed under **GPL-3.0-only**. This plugin only automates downloading
and building them; it does not include their source code.
