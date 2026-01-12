# Perl XS for Rust

High-level Rust bindings to Perl XS API, allowing you to write Perl extensions in Rust.

## Example

```rust
xs! {
  package Array::Sum;
  sub sum_array(ctx, array: AV) {
    array.iter().map(|it| it.unwrap_or(0.0)).sum::<NV>()
  }
}
```

For a more complete example see the XSTest package in the `t/` directory.

## Features

- **Safe abstractions** over Perl's low-level XS API
- **Automatic memory management** with proper reference counting
- **Type conversions** between Perl and Rust types
- **Derive macros** for easy struct serialization from Perl hashes
- **Exception handling** that bridges Perl and Rust

## Goals

- Safety
- Correctness
- Speed

Perl XS API is deliberately low-level and requires users to maintain
internal invariants, allowing for very fast code. This package takes a
different approach of encapsulating implementation details to provide a
simpler and safer API.

## Prerequisites

- Perl 5.20+ (tested with 5.38)
- Rust 1.70+

## Quick Start

### Building

```shell
# Build the workspace
cargo build --workspace

# Run tests
cargo test --workspace --lib
```

### Using Taskfile (Optional)

If you have [Task](https://taskfile.dev) installed:

```shell
# Show available commands
task

# Build
task build

# Run tests
task test

# Check formatting and lint
task ci
```

## Project Structure

```
perl-xs/
├── src/           # Main perl-xs crate (high-level bindings)
├── perl-sys/      # Low-level Perl FFI bindings (auto-generated)
├── perlxs_derive/ # Procedural macros (#[derive(FromPerlKV)])
└── t/             # Perl integration tests
```

## Creating a Perl Module with Rust

1. Add `perl-xs` and `perlxs_derive` to your `Cargo.toml`:

```toml
[dependencies]
perl-xs = "0.2"
perlxs_derive = "0.2"
```

2. Write your XS module:

```rust
#[macro_use]
extern crate perl_xs;
#[macro_use]
extern crate perl_sys;

use perl_xs::{IV, NV, SV, AV, HV};

xs! {
    package MyModule;

    sub add(ctx, a: IV, b: IV) {
        a + b
    }

    sub greet(ctx, name: String) {
        format!("Hello, {}!", name)
    }
}
```

3. Use `Module::Install::Rust` to integrate with Perl's build system.

## Derive Macros

The `perlxs_derive` crate provides `#[derive(FromPerlKV)]` for automatically
converting Perl hashes to Rust structs:

```rust
use perlxs_derive::FromPerlKV;

#[derive(FromPerlKV)]
struct Config {
    #[perlxs(key = "host_name")]
    hostname: String,
    port: u16,
    #[perlxs(key = "timeout_seconds")]
    timeout: Option<u32>,
}
```

## Testing Perl Integration

The `t/` directory contains Perl integration tests. To run them, you'll need:

```shell
# Install Perl test dependencies
cpanm Module::Install Module::Install::Rust Test::LeakTrace Test::More Test::Fatal

# Run Perl tests
cd t && perl Makefile.PL && make test
```

## License

BSD-2-Clause

## Contributing

Contributions are welcome! This project aims to make Rust a first-class
citizen for writing Perl extensions.

## Acknowledgments

Originally created by [Vickenty Fesunov](https://github.com/vickenty).
