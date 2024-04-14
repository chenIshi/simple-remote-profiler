#!/bin/bash

# Number of profiling rounds
nrounds=5
# Number of samples each round
nsamples=200
# Sleep time between samples (in seconds)
sleeptime=0.2

# Hostname or IP address of the machine running QEMU with GDB server
rHost="localhost"
# Port number where QEMU GDB server is listening
rPort="1234"

# Record output directory
outDir="glogs"
# Record naming pattern
outFPattern="speedrun"

# set -x

sleep 0.1

check_server_alive() {
	if [ "$rHost" == "localhost" ]; then
		if ! echo >/dev/tcp/localhost/$rPort; then
        	echo "Remote GDB server is not alive. Exiting."
        	exit 1
    	fi
	else
		nc -z "$rHost" "$rPort"
		if [ $? -ne 0 ]; then
			echo "Remote GDB server is not alive. Exiting."
			exit 1
		fi
	fi
}

gdb_connect() {
	rid="$1"
	outFNames="$outFPattern/$outFPattern_$rid.txt"

	# Check if GDB server is alive
    nc -z "$remote_host" "$remote_port"
    if [ $? -ne 0 ]; then
        echo "Remote GDB server is not alive. Exiting."
        exit 1
    fi

	for x in $(seq 1 $nsamples)
	do
		# gdb -ex "set pagination 0" -ex "target remote $remote_host:$remote_port" -ex "thread apply all bt" -ex "detach" -batch
		gdb -batch \
			-ex "set pagination 0" \
			-ex "file target/x86_64-unknown-none/release/asterinas-osdk-bin" \
			-ex "target remote $rHost:$rPort" \
			-ex "thread apply all bt n 10"
	done | \
	awk '
	BEGIN { s = ""; } 
	/^Thread/ { print s; s = ""; } 
	/^\#/ { if (s != "" ) { s = s "," $4} else { s = $4 } } 
	END { print s }' | \
	sort | uniq -c | sort -r -n -k 1,1 > "$outFNames"
}

main() {
	# Create results directory if it doesn't exist
	mkdir -p "$out_directory"

	for rid in $(seq 1 $nrounds)
	do
		gdb_connect "$rid"
		sleep $sleeptime
	done
}

# Call main function with command line arguments
main "$@"
