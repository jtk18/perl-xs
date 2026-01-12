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

// Diagnostic module to verify bootstrap works
mod diagnostic {
    xs! {
        package XSTest::Diagnostic;

        sub bootstrap_ran(ctx) {
            1 as perl_xs::IV
        }

        sub function_count(ctx) {
            let count = super::stack::PERL_XS.len() +
                        super::scalar::PERL_XS.len() +
                        super::array::PERL_XS.len() +
                        super::hash::PERL_XS.len() +
                        super::panic::PERL_XS.len() +
                        super::param::PERL_XS.len() +
                        super::data::PERL_XS.len() +
                        super::derive::PERL_XS.len() +
                        super::roundtrip::PERL_XS.len();
            count as perl_xs::IV
        }
    }
}

xs! {
    bootstrap boot_XSTest;
    use stack;
    use scalar;
    use array;
    use hash;
    use panic;
    use param;
    use data;
    use derive;
    use roundtrip;
    use diagnostic;
}
