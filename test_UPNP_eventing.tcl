set S_server [socket -server "New_connection" 0]

proc New_connection {chan ip port} {
	puts "New_connection $chan $ip $port"
	fconfigure $chan -blocking 0
	fileevent  $chan readable [list Read_UPNP_event $chan]
}

proc Read_UPNP_event {chan} {
	if {[eof $chan]} {close $chan; return}
	puts "Received:\n[read $chan]"
}


set S_client [socket 129.88.66.127 64007]
set msg "SUBSCRIBE /_urn:schemas-upnp-org:service:ContentDirectory_event HTTP/1.1
TIMEOUT: Second-300
HOST: 129.88.66.127:64007
CALLBACK: <http://129.88.66.127:[lindex [fconfigure $S_server -sockname] end]>
NT: upnp:event
Content-Length: 0
"

puts $S_client $msg; flush $S_client
