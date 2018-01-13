#!@expect@/bin/expect

if {$argc < "2"} {
    send_user "$argv0 timeout script\n"
    send_user "\n"
    send_user "Example: $argv 5 fetchmail.sh\n"
    exit 1
}


set timeout [lindex $argv 0]
exit -onexit {
    catch {close}
    wait
}

spawn {*}[lrange $argv 1 end]


expect {
    -re ".+" {
        exp_continue
    }

    timeout {
        send_user "\n<timeout>\n"
    }

    eof {
        send_user "\n<eof>\n"
    }
}
