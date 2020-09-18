use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, Stdio};
use zbus::dbus_interface;

pub struct GuiDuckInterface {
    executables: HashMap<String, String>,
}

impl GuiDuckInterface {
    pub fn with_executables(executables: HashMap<String, String>) -> Self {
        GuiDuckInterface { executables }
    }

    fn handle_request(&self, cwd: PathBuf, utility: String, arg: Option<&str>) -> bool {
        self.log_launch_request(&cwd, &utility, arg);
        let ret = self.spawn(cwd, utility, arg);
        if let Err(e) = ret {
            self.log_launch_error(e);
            return false;
        } else {
            return true;
        }
    }

    fn spawn(
        &self,
        cwd: PathBuf,
        utility: String,
        arg: Option<&str>,
    ) -> Result<Child, LaunchError> {
        let program = self
            .executables
            .get(&utility)
            .ok_or_else(|| LaunchError::UnknownUtility(utility.clone()))?;

        let mut cmd = Command::new(program);
        cmd.current_dir(cwd);
        cmd.stdin(Stdio::null());
        cmd.stdout(Stdio::inherit());
        cmd.stderr(Stdio::inherit());

        if let Some(arg) = arg {
            cmd.arg(arg);
        }

        cmd.spawn().map_err(|e| LaunchError::FailedToStart {
            cmd: program.to_string(),
            utility,
            e,
        })
    }

    fn log_launch_error(&self, e: LaunchError) {
        match e {
            LaunchError::UnknownUtility(util) => {
                println!("Received a request to spawn an unknown utility «{}»", util);
            }
            LaunchError::FailedToStart { utility, cmd, e } => {
                println!(
                    "Failed to spawn «{}» with command «{}»: «{:?}»",
                    utility, cmd, e
                );
            }
        }
    }

    fn log_launch_request(&self, cwd: &Path, utility: &str, arg: Option<&str>) {
        println!(
            "Launch request for «{}» and arg: {} in «{}»",
            utility,
            arg.map_or_else(|| String::from("-none-"), |a| format!("«{}»", a)),
            cwd.display()
        );
    }
}

#[dbus_interface(name = "com.grahamc.GuiDuck1")]
impl GuiDuckInterface {
    fn xdg_open(&self, cwd: String, utility: String) -> bool {
        self.handle_request(PathBuf::from(cwd), utility, None)
    }

    fn xdg_open_arg(&self, cwd: String, utility: String, arg: &str) -> bool {
        self.handle_request(PathBuf::from(cwd), utility, Some(arg))
    }
}

enum LaunchError {
    UnknownUtility(String),
    FailedToStart {
        utility: String,
        cmd: String,
        e: std::io::Error,
    },
}
