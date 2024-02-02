import run.sh
import logging.sh
import secrets.sh

: ${_DEV_SUSPEND_JVM:=n}
_java_debug() {
	_DEBUG_ARGS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=$_SUSPEND_JVM,address=$_CONF_DEV_DEBUG_PORT"
}

_java_new_instance() {
	_ORIGINAL_APPLICATION=$_APPLICATION

	cp $_APPLICATION $_RUN_INSTANCE_DIR

	_APPLICATION=$_RUN_INSTANCE_DIR/$(basename $_APPLICATION)

	_call _java_new_instance_$_JAVA_FRAMEWORK
}

_run_java_locate_application() {
	if [ -z "$_APPLICATION" ]; then
		_APPLICATION=$(find target -maxdepth 1 -type f ! -name '*.javadoc' ! -name '*.sources' ! -name '*.jar.original' -name '*.jar')
	fi
}

_run_java_init() {
	[ -n "$_JAVA_FRAMEWORK" ] && {
		_require_file $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/run/java/framework/${_JAVA_FRAMEWORK}.sh
		_optional_include $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/run/java/framework/${_JAVA_FRAMEWORK}.sh
	}

	_run_java_locate_application

	[ -z "$_APPLICATION" ] && _error "_APPLICATION is not defined, unable to run application"

	[ $_DEV_SUSPEND ] && {
		_DEV_DEBUG=1
		_DEV_SUSPEND_JVM="y"
	}
	[ $_DEV_DEBUG ] && _java_debug
}

_run_java() {
	if [ -n "$_DEV_AGENT" ]; then
		_require_file "$_DEV_AGENT" _DEV_AGENT
		_AGENT_ARGS="${_AGENT_ARGS} -javaagent:$_DEV_AGENT"
	fi

	java $_AGENT_ARGS $_DEBUG_ARGS $_DEV_ARGS -jar $_APPLICATION "$@" >>$_LOG_FILE 2>&1 &
	_RUN_PID=$!

}

