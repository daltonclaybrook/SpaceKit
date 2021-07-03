mod helpers;

use helpers::*;
use astro::planet::heliocent_coords;
use astro::time::*;
use std::os::raw::{c_double, c_short, c_char, c_uchar, c_void};
use std::ffi::CString;
use std::sync::{Arc, Mutex};
use std::thread;

/// A number representing a day on the Julian calendar
pub type JulianDay = c_double;
/// A callback function for asynchronously fetching the NASA astronomy photo of the day
pub type PhotoCallback = extern "C" fn(photo: *mut PhotoInfo, context: *mut c_void);

/// The planets of our solar system
#[repr(C)]
#[derive(Copy, Clone)]
pub enum Planet {
    Mercury,
    Venus,
    Earth,
    Mars,
    Jupiter,
    Saturn,
    Uranus,
    Neptune,
}

#[repr(C)]
#[derive(Debug)]
pub struct Coordinates {
    /// Heliocentric longitude in radians
    pub longitude: c_double,
    /// Heliocentric latitude in radians
    pub latitude: c_double,
    /// Heliocentric radius vector in AU
    pub radius_vector: c_double,
}

#[repr(C)]
#[derive(Debug)]
pub struct PhotoInfo {
    /// Photo title
    pub title: *const c_char,
    /// Photo explanation
    pub explanation: *const c_char,
    /// Photo URL
    pub url: *const c_char,
    /// HD Photo URL
    pub hd_url: *const c_char,
}

/// Returns a representation of a Julian day, which is required by other functions.
///
/// # Arguments
///
/// * `year` - The year component of the date
/// * `month` - The month component of the date. (1 - 12)
/// * `decimal_day` - The day component of the date provided as a fraction (1.0 - 31.0)
#[no_mangle]
pub extern fn julian_day_from_date(year: c_short, month: c_uchar, decimal_day: c_double) -> JulianDay {
    julian_day(&Date {
        year,
        month,
        decimal_day,
        cal_type: CalType::Gregorian
    })
}

/// Returns the heliocentric coordinates of a provide planet on a provided day
///
/// # Arguments
///
/// * `planet` - The planet to determine coordinates for
/// * `date` - The Julian day used to determine coordinates
#[no_mangle]
pub extern fn heliocentric_coordinates(planet: Planet, day: JulianDay) -> Coordinates {
    let (long, lat, rad_vec) = heliocent_coords(&planet.into(), day);
    Coordinates {
        longitude: long,
        latitude: lat,
        radius_vector: rad_vec
    }
}

/// Fetch the NASA Astronomy photo of the day and call the provided function once the
/// request has completed.
///
/// # Arguments
///
/// * `callback` - A pointer to the function that will be called when the request completes
/// * `context` - A pointer to application-defined context data. This data will be passed
/// to the provided callback function along with the photo info.
#[no_mangle]
pub extern fn fetch_photo_of_the_day(callback: PhotoCallback, context: *mut c_void) {
    // This works without `Arc`, but it seems to be conventional Rust to use both Arc and Mutex
    // together when passing data between threads.
    let lock = Arc::new(Mutex::new(PtrWrapper { void_ptr: context }));
    thread::spawn(move || {
        let result = fetch_photo();
        let context = lock.lock().unwrap().void_ptr;

        let result = match result {
            Some(info) => info,
            None => return callback(std::ptr::null_mut(), context),
        };

        let title = CString::new(result.title).unwrap();
        let explanation = CString::new(result.explanation).unwrap();
        let url = CString::new(result.url).unwrap();
        let hd_url = CString::new(result.hdurl).unwrap();
        
        let mut info = PhotoInfo {
            title: title.as_ptr(),
            explanation: explanation.as_ptr(),
            url: url.as_ptr(),
            hd_url: hd_url.as_ptr(),
        };

        let info_ptr = &mut info as *mut PhotoInfo;
        callback(info_ptr, context);
    });
}
