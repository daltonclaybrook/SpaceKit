use space_kit::*;
use std::ptr;
use std::os::raw::c_void;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let day = julian_day_from_date(2021, 9, 25.0);
    let coords = heliocentric_coordinates(Planet::Earth, day);
    println!("Coordinates: {:?}", coords);

    fetch_photo_of_the_day(photo_callback, ptr::null_mut());

    Ok(())
}

extern "C" fn photo_callback(photo: PhotoInfo, context: *mut c_void) {
    println!("photo: {:?}", photo);
}