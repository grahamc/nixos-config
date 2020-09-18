use std::env;
use std::error::Error;
use std::process::exit;
mod proxy;

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = env::args();
    let orig_utility = args.next().expect("No argv0 -- how does this happen?");
    let utility = orig_utility
        .split("/")
        .last()
        .expect("final path segment is empty somehow");
    let arg = args.next();
    if args.next().is_some() {
        println!("Too many arguments, only argv0 and argv1 are considered.");
        exit(1);
    }

    let connection = zbus::Connection::new_session()?;

    let proxy = proxy::GuiDuckProxy::new(&connection)?;

    let current_dir_path: std::path::PathBuf = std::env::current_dir()?;
    let cwd = current_dir_path.to_str().expect("cwd isn't stringy");

    if let Some(arg) = arg {
        let reply = proxy.xdg_open_arg(cwd, &utility, &arg)?;
        dbg!(reply);
    } else {
        let reply = proxy.xdg_open(cwd, &utility)?;
        dbg!(reply);
    }

    Ok(())
}
