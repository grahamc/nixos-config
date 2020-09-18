use zbus::dbus_proxy;

#[dbus_proxy(
    interface = "com.grahamc.GuiDuck1",
    default_service = "com.grahamc.guiduck",
    default_path = "/com/grahamc/guiduck1"
)]
trait GuiDuck {
    fn xdg_open(&self, cwd: &str, utility: &str) -> zbus::Result<bool>;

    fn xdg_open_arg(&self, cwd: &str, utility: &str, arg: &str) -> zbus::Result<bool>;
}
