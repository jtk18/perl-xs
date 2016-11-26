#[macro_use]
extern crate perl_xs;
#[macro_use]
extern crate perl_sys;

mod stack;
mod scalar;
mod array;
mod hash;
mod panic;
mod param;

xs! {
    bootstrap boot_XSTest;
    use stack;
    use scalar;
    use array;
    use hash;
    use panic;
    use param;
}
