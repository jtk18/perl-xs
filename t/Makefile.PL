use inc::Module::Install;

name "XSTest";
version "0.01";
abstract "Tests for perl-xs";

configure_requires "Module::Install::Rust" => 0;
test_requires "Test::LeakTrace" => 0;
test_requires "Test::More" => 0;
test_requires "Test::Fatal" => 0;
requires "XSLoader" => 0;

rust_use_perl_xs { path => ".." };

# The test crate needs these dependencies directly (for macros in lib.rs)
# Note: perl-sys path must match what perl-xs expects
rust_requires "perl-sys" => { path => "../perl-sys" };
rust_requires "perlxs_derive" => { path => "../perlxs_derive" };
rust_requires "cstr" => "0.2";

# Set crate type to cdylib for dynamic loading
rust_profile release => { lto => "false" };
rust_write;

WriteAll;
