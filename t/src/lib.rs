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

// MANUAL XS function - bypassing xs! macro to test raw registration
pthx! {
    fn manual_test_fn(pthx, _cv: *mut perl_xs::raw::CV) {
        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            ctx.st_push(42 as perl_xs::IV);
        });
    }
}

// Manual bootstrap - registers ONE function directly to test the mechanism
pthx! {
    #[unsafe(no_mangle)]
    #[allow(non_snake_case)]
    fn boot_XSTest(pthx, _cv: *mut perl_xs::raw::CV) {
        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            eprintln!("=== XSTest boot_XSTest starting ===");

            // Register our manual test function
            let name = std::ffi::CString::new("XSTest::manual_test").unwrap();
            ctx.new_xs(&name, manual_test_fn as perl_xs::raw::XSUBADDR_t);
            eprintln!("Registered: XSTest::manual_test");

            // Debug: print PERL_XS array sizes
            eprintln!("stack::PERL_XS has {} entries", stack::PERL_XS.len());
            eprintln!("scalar::PERL_XS has {} entries", scalar::PERL_XS.len());
            eprintln!("array::PERL_XS has {} entries", array::PERL_XS.len());
            eprintln!("hash::PERL_XS has {} entries", hash::PERL_XS.len());
            eprintln!("panic::PERL_XS has {} entries", panic::PERL_XS.len());
            eprintln!("param::PERL_XS has {} entries", param::PERL_XS.len());
            eprintln!("data::PERL_XS has {} entries", data::PERL_XS.len());
            eprintln!("derive::PERL_XS has {} entries", derive::PERL_XS.len());
            eprintln!("roundtrip::PERL_XS has {} entries", roundtrip::PERL_XS.len());

            // Also register functions from modules
            for &(subname, subptr) in stack::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in scalar::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in array::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in hash::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in panic::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in param::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in data::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in derive::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }
            for &(subname, subptr) in roundtrip::PERL_XS {
                eprintln!("Registering: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }

            eprintln!("=== XSTest boot_XSTest complete ===");
            1 as perl_xs::raw::IV
        });
    }
}
