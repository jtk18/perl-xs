# Learning

Trying to learn how this is all wired together in effort to contribute.

## Running tests

`prove -wlmv -Iblib/arch -Iblib/lib  -Iinc t/hash.**t**`

## SV

`perl-xs/t/t/scalar-new.t`

```perl
cmp_ok XSTest::test_new_sv_iv(42), "==", 42, "iv ok";
cmp_ok XSTest::test_new_sv_nv(42**0.5), "==", 42**0.5, "nv ok";
ok !defined(XSTest::test_new_sv_undef()), "undef ok";
```

`perl-xs/t/src/scalar.rs`

```rust
sub test_new_sv_iv(ctx, iv: IV) {
    ctx.new_sv(iv)
}

sub test_new_sv_nv(ctx, nv: NV) {
    ctx.new_sv(nv)
}

sub test_new_sv_undef(ctx) {
    ctx.sv_undef()
}
```

`perl-xs/src/context.rs`

```rust
/// Allocate new SV of type appropriate to store `T`
#[inline]
pub fn new_sv<T>(&mut self, val: T) -> SV
where
    T: IntoSV,
{
    val.into_sv(self.perl)
}
```

`perl-xs/src/convert.rs`

```rust
/// Fast unsafe conversion from raw SV pointer.
pub trait FromSV {
    /// Perform the conversion.
    unsafe fn from_sv(perl: raw::Interpreter, raw: *mut raw::SV) -> Self;
}

/// Construct new `SV` from `self`.
pub trait IntoSV {
    /// Perform the conversion.
    fn into_sv(self, perl: raw::Interpreter) -> SV;
}

impl<T> IntoSV for Option<T>
where
    T: IntoSV,
{
    fn into_sv(self, perl: raw::Interpreter) -> SV {
        match self {
            Some(inner) => inner.into_sv(perl),
            None => unsafe { SV::from_raw_owned(perl, perl.ouroboros_sv_undef()) },
        }
    }
}

/// Attempt unsafe conversion from a raw SV pointer.
pub trait TryFromSV: Sized {
    /// The type returned in the event of a conversion error.
    type Error: Display;
    /// Perform the conversion.
    unsafe fn try_from_sv(perl: raw::Interpreter, raw: *mut raw::SV) -> Result<Self, Self::Error>;
}

impl<T> TryFromSV for T
where
    T: FromSV,
{
    type Error = &'static str;
    unsafe fn try_from_sv(perl: raw::Interpreter, raw: *mut raw::SV) -> Result<T, Self::Error> {
        Ok(T::from_sv(perl, raw))
    }
}
```

`perl-xs/src/scalar.rs`

```rust
impl IntoSV for IV {
    #[inline]
    fn into_sv(self, pthx: raw::Interpreter) -> SV {
        unsafe { SV::from_raw_owned(pthx, pthx.newSViv(self)) }
    }
}

impl IntoSV for Box<dyn Any> {
    fn into_sv(self, pthx: raw::Interpreter) -> SV {
        let sv = unsafe { SV::from_raw_owned(pthx, pthx.newSV(0)) };
        sv.add_data(self);
        sv.into_ref()
    }
}

impl IntoSV for SV {
    #[inline]
    fn into_sv(self, pthx: raw::Interpreter) -> SV {
        assert!(self.pthx() == pthx);
        self
    }
}

impl<'a> IntoSV for &'a SV {
    #[inline]
    fn into_sv(self, pthx: raw::Interpreter) -> SV {
        assert!(self.pthx() == pthx);
        self.clone()
    }
}
```