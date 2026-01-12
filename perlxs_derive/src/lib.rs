//! Derive macros for perl-xs.
//!
//! Provides `#[derive(FromPerlKV)]` for deserializing Perl key-value pairs into Rust structs.

use proc_macro::TokenStream;
use proc_macro2::TokenStream as TokenStream2;
use quote::{format_ident, quote};
use syn::{Attribute, Data, DeriveInput, Fields, Ident, LitStr, Type, parse_macro_input};

/// Derive `FromPerlKV` for a struct.
///
/// This allows converting Perl key-value pairs (like from a hash or argument list)
/// into a Rust struct.
///
/// # Attributes
///
/// - `#[perlxs(key = "alternative_name")]` - Use alternative key name(s) for a field
///
/// # Example
///
/// ```ignore
/// #[derive(FromPerlKV)]
/// struct Config {
///     #[perlxs(key = "host_name")]
///     hostname: String,
///     port: u16,
///     #[perlxs(key = "timeout_seconds")]
///     timeout: Option<u32>,
/// }
/// ```
#[proc_macro_derive(FromPerlKV, attributes(perlxs))]
pub fn from_kv(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let expanded = impl_from_kv(&input);
    TokenStream::from(expanded)
}

/// Represents a parsed field with its metadata
struct FieldInfo {
    ident: Ident,
    ty: Type,
    keys: Vec<String>,
    optional: bool,
}

/// Parse perlxs attributes from a field
fn parse_field_attrs(attrs: &[Attribute]) -> Vec<String> {
    let mut keys = Vec::new();

    for attr in attrs {
        if !attr.path().is_ident("perlxs") {
            continue;
        }

        // Parse #[perlxs(key = "value")] or #[perlxs(key = "value1", key = "value2")]
        let _ = attr.parse_nested_meta(|meta| {
            if meta.path.is_ident("key") {
                let value: LitStr = meta.value()?.parse()?;
                keys.push(value.value());
            }
            Ok(())
        });
    }

    keys
}

/// Check if a type is Option<T>
fn is_option_type(ty: &Type) -> bool {
    if let Type::Path(type_path) = ty {
        if let Some(segment) = type_path.path.segments.last() {
            return segment.ident == "Option";
        }
    }
    false
}

/// Extract field information from struct fields
fn extract_fields(fields: &Fields) -> Vec<FieldInfo> {
    match fields {
        Fields::Named(named) => {
            named
                .named
                .iter()
                .filter_map(|f| {
                    let ident = f.ident.clone()?;
                    let ty = f.ty.clone();

                    // Get keys from attributes or use field name
                    let mut keys = parse_field_attrs(&f.attrs);
                    if keys.is_empty() {
                        keys.push(ident.to_string());
                    }

                    let optional = is_option_type(&ty);

                    Some(FieldInfo { ident, ty, keys, optional })
                })
                .collect()
        }
        _ => panic!("FromPerlKV can only be derived for structs with named fields"),
    }
}

fn impl_from_kv(input: &DeriveInput) -> TokenStream2 {
    let name = &input.ident;
    let name_str = name.to_string();
    let (impl_generics, ty_generics, where_clause) = input.generics.split_for_impl();

    // Extract struct fields
    let fields = match &input.data {
        Data::Struct(data) => extract_fields(&data.fields),
        _ => panic!("FromPerlKV can only be derived for structs"),
    };

    // Generate variable declarations
    // For optional fields (Option<T>), we use Option<T> directly
    // For required fields, we use Option<T> to track if it was set
    let var_decls: Vec<_> = fields
        .iter()
        .map(|f| {
            let var_name = format_ident!("value_{}", f.ident);
            let ty = &f.ty;
            if f.optional {
                // Field is already Option<T>, so just use that type
                quote! {
                    let mut #var_name: #ty = None
                }
            } else {
                // Wrap in Option to track if it was set
                quote! {
                    let mut #var_name: Option<#ty> = None
                }
            }
        })
        .collect();

    // Generate match arms for each field
    let match_arms: Vec<_> = fields
        .iter()
        .flat_map(|f| {
            let var_name = format_ident!("value_{}", f.ident);
            let ty = &f.ty;
            let ty_str = quote!(#ty).to_string();
            let is_optional = f.optional;

            f.keys
                .iter()
                .map(move |key| {
                    // For optional fields, assign the value directly (it's already Option<T>)
                    // For required fields, wrap in Some() to track that it was set
                    let assign = if is_optional {
                        quote! { #var_name = v; }
                    } else {
                        quote! { #var_name = Some(v); }
                    };
                    quote! {
                        #key => {
                            match ctx.st_try_fetch::<#ty>(i + 1) {
                                Some(Ok(v)) => {
                                    #assign
                                },
                                Some(Err(e)) => {
                                    errors.push(_perlxs::error::ToStructErrPart::ValueParseFail {
                                        key: #key,
                                        ty: #ty_str,
                                        error: e.to_string(),
                                        offset: i + 1,
                                    });
                                },
                                None => {
                                    errors.push(_perlxs::error::ToStructErrPart::OmittedValue(#key));
                                },
                            }
                        }
                    }
                })
                .collect::<Vec<_>>()
        })
        .collect();

    // Generate required field checks
    let required_checks: Vec<_> = fields
        .iter()
        .filter(|f| !f.optional)
        .map(|f| {
            let var_name = format_ident!("value_{}", f.ident);
            let keys: Vec<_> = f.keys.iter().map(|k| quote!(#k)).collect();
            quote! {
                if #var_name.is_none() {
                    errors.push(_perlxs::error::ToStructErrPart::OmittedKey(&[#(#keys),*]));
                }
            }
        })
        .collect();

    // Generate struct field initializers
    let field_inits: Vec<_> = fields
        .iter()
        .map(|f| {
            let ident = &f.ident;
            let var_name = format_ident!("value_{}", f.ident);
            if f.optional {
                quote! { #ident: #var_name }
            } else {
                quote! { #ident: #var_name.unwrap() }
            }
        })
        .collect();

    let dummy_const = format_ident!("_IMPL_PERLXS_FROMPERLKV_FOR_{}", name);

    quote! {
        #[allow(non_upper_case_globals)]
        const #dummy_const: () = {
            extern crate perl_xs as _perlxs;

            impl #impl_generics _perlxs::FromPerlKV for #name #ty_generics #where_clause {
                fn from_perl_kv(
                    ctx: &mut _perlxs::Context,
                    offset: isize
                ) -> Result<Self, _perlxs::error::ToStructErr> {
                    let mut errors = Vec::new();

                    #(#var_decls;)*

                    let mut i = offset;
                    while let Some(sv_res) = ctx.st_try_fetch::<String>(i) {
                        match sv_res {
                            Ok(key) => {
                                match &*key {
                                    #(#match_arms,)*
                                    _ => {
                                        // Unknown key - could warn here
                                    }
                                }
                            },
                            Err(e) => {
                                errors.push(_perlxs::error::ToStructErrPart::KeyParseFail {
                                    offset: i,
                                    ty: "String",
                                    error: e.to_string(),
                                });
                            }
                        }
                        i += 2;
                    }

                    #(#required_checks;)*

                    if !errors.is_empty() {
                        return Err(_perlxs::error::ToStructErr {
                            name: #name_str,
                            errors,
                        });
                    }

                    Ok(Self {
                        #(#field_inits,)*
                    })
                }
            }
        };
    }
}
