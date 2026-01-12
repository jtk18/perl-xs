#[macro_use]
extern crate cstr;
#[macro_use]
extern crate perl_xs;
#[macro_use]
extern crate perl_sys;
#[macro_use]
extern crate perlxs_derive;

mod stack;
mod scalar;
mod array;
mod hash;
mod panic;
mod param;
mod data;
mod derive;
mod roundtrip;

// Minimal test module - if this one function gets registered, bootstrap works
mod minimal {
    xs! {
        package XSTest::Minimal;

        sub test(ctx) {
            42 as perl_xs::IV
        }
    }
}

xs! {
    bootstrap boot_XSTest;
    use minimal;
    use stack;
    use scalar;
    use array;
    use hash;
    use panic;
    use param;
    use data;
    use derive;
    use roundtrip;
}
