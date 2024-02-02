import git:install/sed.sh
import colored-tail.sh

_capture_env() {
	_RUN_LOG_FILE=.log/$(date +%Y.%m.%d.%H.%M.%S)
	mkdir -p $(dirname $_RUN_LOG_FILE)

	if [ -n "$_LOG_FILE" ]; then
		printf '@see: %s\n' "$_LOG_FILE" >$_RUN_LOG_FILE
		return
	fi

	_LOG_FILE=$_RUN_LOG_FILE

	printf '# run: %s:%s\n' "$(date)" "$PWD" >$_RUN_LOG_FILE
	printf '# git: %s:%s\n' "$(gcb)" "$(git-head)" >>$_RUN_LOG_FILE
	printf '# cmdline: %s\n' "$@" >>$_RUN_LOG_FILE
	printf '# env - start\n' >>$_RUN_LOG_FILE
	env | _sed_remove_nonprintable_characters >>$_RUN_LOG_FILE
	printf '# env - end\n' >>$_RUN_LOG_FILE
}

_open_log() {
	[ -n "$_OPEN_LOG" ] && less +G $_RUN_LOG_FILE
}

_tail() {
	[ -z "$_TAIL" ] && return 1

	_colored_tail &

	_TAIL_PIDS=$!
	_TAIL_PIDS="$_TAIL_PIDS $(_parent_processes $_TAIL_PIDS | tr '\n' ' ')"
}
