use clap::{App, Arg};
use std::collections::HashMap;
use std::convert::TryInto;
use std::error::Error;
use zbus::fdo;
mod interface;

pub const INTERFACE: &str = "com.grahamc.GuiDuck1";
pub const SERVICE: &str = "com.grahamc.guiduck";
pub const PATH: &str = "/com/grahamc/guiduck1";

fn main() -> Result<(), Box<dyn Error>> {
    let matches = App::new("guiduck-launcher")
        .version("1.0")
        .author("Graham Christensen <graham@grahamc.com>")
        .about("Launch GUI programs over dbus, by pretending to be xdg-open's targets")
        .arg(
            Arg::with_name("map")
                .long("map")
                .multiple(true)
                .required(true)
                .number_of_values(2),
        )
        .get_matches();
    let map: HashMap<String, String> = matches
        .values_of("map")
        .unwrap()
        .collect::<Vec<&str>>()
        .chunks(2)
        .into_iter()
        .map(|chunks| {
            // If the following error handling triggers, the clap configuration is bad.
            let key: &str = chunks
                .get(0)
                .expect("Converting --map args to a hashmap: no key");
            let value: &str = chunks.get(1).unwrap_or_else(|| {
                panic!(
                    "Converting --map args to a hashmap: no value for key «{}»",
                    key
                )
            });
            (key.to_owned(), value.to_owned())
        })
        .collect();

    let connection = zbus::Connection::new_session()?;
    fdo::DBusProxy::new(&connection)?
        .request_name(SERVICE, fdo::RequestNameFlags::ReplaceExisting.into())?;

    let mut object_server = zbus::ObjectServer::new(&connection);
    object_server.at(
        &PATH.try_into()?,
        interface::GuiDuckInterface::with_executables(map),
    )?;
    loop {
        if let Err(err) = object_server.try_handle_next() {
            eprintln!("{}", err);
        }
    }
}
