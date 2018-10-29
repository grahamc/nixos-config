#!/usr/bin/python3
# systemd-lock-handler -- proxy between systemd-logind's "Lock" signal and your
#   favourite screen lock command

from __future__ import print_function
import os, sys, dbus, dbus.mainloop.glib
from gi.repository import GLib
from pprint import pprint

def trace(*args):
    global arg0
    print("%s:" % arg0, *args)

def setup_signal(signal_handler):
    bus = dbus.SystemBus()
    manager = bus.get_object("org.freedesktop.login1", "/org/freedesktop/login1")
    # yecch
    manager = dbus.Interface(manager, "org.freedesktop.login1.Manager")
    all_sessions = manager.ListSessions()
    session_ids = [session[0] for session in all_sessions if session[1] == os.getuid()]
    if len(session_ids) > 1:
        print("Found multiple session IDs but this only supports one, bailing:")
        pprint(session_ids)
        pprint(all_sessions)
        abort
    elif not session_ids:
        print("Found no session IDs, bailing:")
        pprint(session_ids)
        pprint(all_sessions)
        abort

    session_path = manager.GetSession(session_ids[0])
    session = bus.get_object("org.freedesktop.login1", session_path)
    session.connect_to_signal("Lock", signal_handler)

def handler_dbus_fdo():
    trace("locking session using DBus")
    bus = dbus.SessionBus()
    screensaver = bus.get_object("org.freedesktop.ScreenSaver", "/ScreenSaver")
    screensaver.Lock()

def handler_external():
    global lock_command
    trace("locking session using %r" % lock_command[0])
    os.spawnvp(os.P_NOWAIT, lock_command[0], lock_command)

def main():
    global arg0, lock_command
    arg0 = sys.argv[0].split("/")[-1]
    lock_command = sys.argv[1:] or ["--dbus"]
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    if lock_command == ["--dbus"]:
        trace("using freedesktop.org DBus API")
        setup_signal(handler_dbus_fdo)
    else:
        trace("using external command %r" % lock_command[0])
        setup_signal(handler_external)
    trace("waiting for lock signals")
    try:
        loop = GLib.MainLoop()
        loop.run()
    except KeyboardInterrupt:
        sys.exit(0)

main()
