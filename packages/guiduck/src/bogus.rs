use std::convert::TryInto;
use std::error::Error;
use zbus::{dbus_interface, fdo};

struct Foo;

#[dbus_interface(name = "com.grahamc.Foo1")]
impl Foo {
    fn bar(&self, name: &str, arg: &str) -> String {
        format!("Hello {} {}!", name, arg)
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let connection = zbus::Connection::new_session()?;
    fdo::DBusProxy::new(&connection)?.request_name(
        "com.grahamc.Foo",
        fdo::RequestNameFlags::ReplaceExisting.into(),
    )?;

    let mut object_server = zbus::ObjectServer::new(&connection);
    object_server.at(&"/com/grahamc/Foo".try_into()?, Foo)?;
    loop {
        println!("hello");
        if let Err(err) = object_server.try_handle_next() {
            eprintln!("{}", err);
        }
    }
}
