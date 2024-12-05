_wait_for() {
	ps -p $_RUN_PID >/dev/null 2>&1

	wait $_RUN_PID
}

_run_cleanup() {
	_info "Run Cleaning up"
	kill -9 $_RUN_PID $_TAIL_PIDS $_NOTIFY_PID 2>/dev/null

	[ -e $_RUN_INSTANCE_DIR ] && rm -rf $_RUN_INSTANCE_DIR
}

_notify_running() {
	[ -z "$_NOTIFY" ] && return 1

	_call _${_LANGUAGE}_is_running

	_notify "$_CONTEXT $(basename $PWD)" "Application Started ($$)" "$_APPLICATION" &

	printf '%s\n' "started" >$_APPLICATION_PIPE &
	_NOTIFY_PID=$!
}

_run_new_instance() {
	[ -z "$_NEW_INSTANCE" ] && return 1

	_RUN_INSTANCE_DIR=$(mktemp -d)

	_info "Creating new instance in $_RUN_INSTANCE_DIR"

	_call _${_LANGUAGE}_new_instance
}

_run() {
	_defer _run_cleanup

	_call _run_${_LANGUAGE}_init "$@"
	_run_new_instance

	_capture_env "$@"
	_call _run_${_LANGUAGE} "$@"

	_tail
	_notify_running

	_wait_for

	_open_log
}
