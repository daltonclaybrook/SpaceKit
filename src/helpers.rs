use astro::planet::Planet as AstroPlanet;
use std::os::raw::c_void;
use serde::Deserialize;
use super::Planet;

#[derive(Deserialize)]
pub struct PhotoResult {
    pub title: String,
    pub explanation: String,
    pub url: String,
    pub hdurl: String,
}

/// A wrapper for a void pointer that implements `Send` so it can be
/// passed across thread boundaries.
pub struct PtrWrapper {
    pub void_ptr: *mut c_void,
}
unsafe impl Send for PtrWrapper {}

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

pub fn fetch_photo(api_key: &str) -> Option<PhotoResult> {
    let url = format!("https://api.nasa.gov/planetary/apod?api_key={}", api_key);
    let response = reqwest::blocking::get(&url).ok()?;
    response.json::<PhotoResult>().ok()
}
