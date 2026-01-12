#![deny(missing_docs)]

//! Perl XS API for Rust.

#[macro_use]
extern crate perl_sys;

#[macro_use]
mod macros;
#[macro_use]
mod helper_macros;

mod handle;
#[allow(missing_docs)]
pub mod raw;

mod array;
pub mod context;
pub mod convert;
pub mod error;
mod hash;
mod scalar;

#[doc(hidden)]
pub mod croak;

pub use crate::array::AV;
pub use crate::context::Context;
pub use crate::convert::FromPerlKV;
pub use crate::hash::HV;
pub use crate::raw::{G_DISCARD, G_VOID};
pub use crate::raw::{IV, NV, SSize_t, STRLEN, Size_t, UV};
pub use crate::scalar::{DataRef, SV};
