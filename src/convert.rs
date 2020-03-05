//! Traits for converting to and from Perl scalars.

use crate::context::Context;
use crate::error;
use crate::raw;
use crate::{AV, SV};
use std::fmt::Display;

/// Conversion from AV.
pub trait FromAV {
    /// Perform the conversion.
    unsafe fn from_av(perl: raw::Interpreter, raw: *mut raw::AV) -> Self;
}

/// Construct new `AV` from `self`.
pub trait IntoAV {
    /// Perform the conversion.
    fn into_av(self, perl: raw::Interpreter) -> AV;
}

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

/// Attempt unsafe conversion from a raw AV pointer.
pub trait TryFromAV: Sized {
    /// The type returned in the event of a conversion error.
    type Error: Display;
    /// Perform the conversion.
    unsafe fn try_from_av(perl: raw::Interpreter, raw: *mut raw::AV) -> Result<Self, Self::Error>;
}

impl<T> TryFromAV for T
where
    T: FromAV,
{
    type Error = &'static str;
    unsafe fn try_from_av(perl: raw::Interpreter, raw: *mut raw::AV) -> Result<T, Self::Error> {
        Ok(T::from_av(perl, raw))
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

/// Construct new `Self` from `key value pairs of the XSUB context`.
pub trait FromPerlKV {
    /// create a struct from HV or key-value pairs on the stack, similar to a Moose constructor
    /// offset is the starting positon in the stack we should consider
    fn from_perl_kv(ctx: &mut Context, offset: isize) -> Result<Self, error::ToStructErr>
    where
        Self: Sized;
}
