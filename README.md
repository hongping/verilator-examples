# verilator-examples

Small SystemVerilog examples built and run with [Verilator](https://verilator.org/).

## Examples

- `example/helloworld` prints `Hello World` from a SystemVerilog testbench.
- `example/pyhdl-if` demonstrates calling Python code from SystemVerilog through [`pyhdl-if`](https://github.com/fvutils/pyhdl-if), including simulated delays and simulation-time queries.

## Prerequisites

- Set `VERILATOR_ROOT` to Verilator installation directory.
- GNU Make.
- Clang, including `clang++`, for compiling the UVM example.
- [`uv`](https://docs.astral.sh/uv/) for running IVPM.

On Debian or Ubuntu, install Clang with:

```sh
sudo apt install clang
```

## Set up dependencies

This repository uses [`ivpm`](https://github.com/fvutils/ivpm) to pull and assemble its dependencies. From the repository root, run:

```sh
uvx ivpm sync
source packages/python/bin/activate
```

The `source` command is for Bash. IVPM is only needed for examples that use dependencies declared in `ivpm.yaml`; standalone examples such as `example/helloworld` can be run without this setup.

## Run an example

From the repository root:

```sh
cd example/helloworld
make run
```

To run the Python/SystemVerilog bridge example:

```sh
cd example/pyhdl-if
make run
```

Each example builds its executable under a local `output/` directory. Remove generated files with:

```sh
make clean
```

## Configuration

The Makefiles use `verilator` from `PATH` by default. To use a specific executable:

```sh
VERILATOR=/path/to/verilator/bin/verilator make run
```

The `pyhdl-if` example also discovers its shared DPI files and libraries through the installed `pyhdl-if` command. `PYHDL_IF_SHARE`, `PYHDL_IF_LIBS`, `PYHDL_IF_LIBDIR`, and `PYTHONPATH` can be overridden when needed.

## License

See [LICENSE](LICENSE).
