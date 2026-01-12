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

// Debug function that returns the PERL_XS array sizes as a string
pthx! {
    fn get_perl_xs_sizes(pthx, _cv: *mut perl_xs::raw::CV) {
        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            let info = format!(
                "stack={} scalar={} array={} hash={} panic={} param={} data={} derive={} roundtrip={}",
                stack::PERL_XS.len(),
                scalar::PERL_XS.len(),
                array::PERL_XS.len(),
                hash::PERL_XS.len(),
                panic::PERL_XS.len(),
                param::PERL_XS.len(),
                data::PERL_XS.len(),
                derive::PERL_XS.len(),
                roundtrip::PERL_XS.len()
            );
            ctx.st_push(&info[..]);
        });
    }
}

// Debug function that returns first function name from stack::PERL_XS
pthx! {
    fn get_first_stack_fn(pthx, _cv: *mut perl_xs::raw::CV) {
        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            if let Some(&(name, _)) = stack::PERL_XS.first() {
                ctx.st_push(name);
            } else {
                ctx.st_push("EMPTY");
            }
        });
    }
}

// Second manual test function to verify array iteration works
pthx! {
    fn manual_test_fn2(pthx, _cv: *mut perl_xs::raw::CV) {
        let perl = perl_xs::raw::initialize(pthx);
        perl_xs::context::Context::wrap(perl, |ctx| {
            ctx.st_push(99 as perl_xs::IV);
        });
    }
}

// Manual PERL_XS array to test if iteration works
pub const MANUAL_PERL_XS: &'static [(&'static str, perl_xs::raw::XSUBADDR_t)] = &[
    ("XSTest::manual_from_array", manual_test_fn2 as perl_xs::raw::XSUBADDR_t),
];

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

            // Register debug functions
            let name = std::ffi::CString::new("XSTest::get_perl_xs_sizes").unwrap();
            ctx.new_xs(&name, get_perl_xs_sizes as perl_xs::raw::XSUBADDR_t);
            let name = std::ffi::CString::new("XSTest::get_first_stack_fn").unwrap();
            ctx.new_xs(&name, get_first_stack_fn as perl_xs::raw::XSUBADDR_t);

            // Test registering from a hardcoded array
            eprintln!("MANUAL_PERL_XS has {} entries", MANUAL_PERL_XS.len());
            for &(subname, subptr) in MANUAL_PERL_XS {
                eprintln!("Registering from manual array: {}", subname);
                let cname = std::ffi::CString::new(subname).unwrap();
                ctx.new_xs(&cname, subptr);
            }

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
