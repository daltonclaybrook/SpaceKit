use astro::planet::{heliocent_coords, Planet as AstroPlanet};
use astro::time::*;
use std::os::raw::{c_double, c_short, c_char, c_uchar, c_void};

/// A number representing a day on the Julian calendar
pub type JulianDay = c_double;
pub type PhotoCallback = extern "C" fn(photo: PhotoInfo, context: *mut c_void);

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
pub struct Coordinates {
    /// Heliocentric longitude in radians
    pub longitude: c_double,
    /// Heliocentric latitude in radians
    pub latitude: c_double,
    /// Heliocentric radius vector in AU
    pub radius_vector: c_double,
}

#[repr(C)]
pub struct PhotoInfo {
    pub description: *const c_char
}

impl From<Planet> for AstroPlanet {
    fn from(planet: Planet) -> Self {
        match planet {
            Planet::Mercury => Self::Mercury,
            Planet::Venus => Self::Venus,
            Planet::Earth => Self::Earth,
            Planet::Mars => Self::Mars,
            Planet::Jupiter => Self::Jupiter,
            Planet::Saturn => Self::Saturn,
            Planet::Uranus => Self::Uranus,
            Planet::Neptune => Self::Neptune,
        }
    }
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
    let result = std::ffi::CString::new("testing...").unwrap();
    let photo = PhotoInfo {
        description: result.as_ptr()
    };
    callback(photo, context)
}
