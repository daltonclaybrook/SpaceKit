use space_kit::*;
use std::ffi::CString;
use std::ptr;
use std::os::raw::c_void;
use std::ffi::CStr;
use tokio::time::{sleep, Duration};
use dotenv::dotenv;
use std::env;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let day = julian_day_from_date(2021, 9, 25.0);
    let coords = heliocentric_coordinates(Planet::Earth, day);
    println!("Coordinates: {:?}", coords);

    dotenv().ok();
    let api_key = env::var("NASA_API_KEY").unwrap();
    let api_key_c = CString::new(api_key).unwrap();
    unsafe {
        fetch_photo_of_the_day(api_key_c.as_ptr(), photo_callback, ptr::null_mut());
    }
    
    sleep(Duration::from_secs(10)).await;
    Ok(())
}

extern "C" fn photo_callback(photo: *mut PhotoInfo, context: *mut c_void) {
    unsafe {
        let info = photo.as_ref().unwrap();
        let url = CStr::from_ptr(info.hd_url).to_str().unwrap();
        println!("photo url: {}", url);
    }
}
