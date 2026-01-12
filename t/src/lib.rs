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

// Debug: Print PERL_XS counts
fn debug_print_counts() {
    eprintln!("DEBUG: stack::PERL_XS has {} entries", stack::PERL_XS.len());
    eprintln!("DEBUG: scalar::PERL_XS has {} entries", scalar::PERL_XS.len());
    eprintln!("DEBUG: array::PERL_XS has {} entries", array::PERL_XS.len());
    eprintln!("DEBUG: hash::PERL_XS has {} entries", hash::PERL_XS.len());
    eprintln!("DEBUG: roundtrip::PERL_XS has {} entries", roundtrip::PERL_XS.len());
}

// Manual bootstrap with debug output
pthx! {
    #[unsafe(no_mangle)]
    #[allow(non_snake_case)]
    fn boot_XSTest(pthx, _cv: *mut perl_xs::raw::CV) {
        eprintln!("DEBUG: boot_XSTest called");
        debug_print_counts();

        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            let mut total = 0;

            for &(subname, subptr) in stack::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in scalar::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in array::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in hash::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in panic::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in param::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in data::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in derive::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }
            for &(subname, subptr) in roundtrip::PERL_XS {
                let cname = ::std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
                total += 1;
            }

            eprintln!("DEBUG: Registered {} XS functions total", total);
            1 as perl_xs::raw::IV
        });
        eprintln!("DEBUG: boot_XSTest completed");
    }
}
