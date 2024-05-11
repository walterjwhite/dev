_ACTION=$(basename $0)

_changed() {
	git status -s | $_CONF_INSTALL_GNU_GREP -P "^(\?\?|A|M)" | awk {'print$2'} | grep "\\.${1}$"
}

_exec_changed() {
	_changed $1 | xargs -P$_CONF_DEV_FORMAT_PARALLEL -I _F $_EXEC_CMD _F
}

_exec_all() {
	local exec_arg=-exec
	[ -n "$_EXEC_DIR_CMD" ] && {
		exec_arg=-execdir
		_EXEC_CMD="$_EXEC_DIR_CMD"
		unset _EXEC_DIR_CMD
	}

	[ -z "$_EXEC_CMD" ] && return 1

	type _$1_find >/dev/null 2>&1 && {
		_$1_find $1 $exec_arg $_EXEC_CMD
		return
	}

	_helper_find $1 $exec_arg $_EXEC_CMD
}

_has_files() {
	type _$1_find >/dev/null 2>&1 && {
		_$1_find $1 -print -quit | wc -l
		return
	}

	_helper_find $1 -print -quit | wc -l
}

_helper_find() {
	local file_extension_pattern="*.$1"
	case $1 in
	*.*)
		file_extension_pattern="$1"
		;;
	esac

	shift

	find . -type f -name "$file_extension_pattern" \
		! -path '*/node_modules/*' \
		! -path '*/target/*' \
		! -path '*/.idea/*' \
		! -path '*/.git/*' \
		$@
}

_helper_run() {
	_FEATURE_NAME=${_ACTION}_${_LANGUAGE}
	_FEATURE_NAME=$(printf '%s' $_FEATURE_NAME | tr '[:lower:]' '[:upper:]')

	_is_feature_enabled $_FEATURE_NAME || {
		unset _FEATURE_NAME
		return 1
	}

	_info "$_ACTION [$(basename $PWD)] ($_LANGUAGE)"
	if [ -z "$_EXEC_CMD" ]; then
		if [ -e $_LANGUAGE_PATH ]; then
			for _EXECUTOR in $(find $_LANGUAGE_PATH $_LANGUAGE_PATH/bin -type f ! -name '.*' -depth 1 2>/dev/null); do
				case $_EXECUTOR in
				$_LANGUAGE_PATH/bin/*)
					_EXEC_CMD="$_EXECUTOR {} +"
					;;
				*)
					. $_EXECUTOR
					;;
				esac

				_helper_run_each
			done

			unset _EXEC_CMD
			return
		fi
	fi

	_do_run
	unset _EXEC_CMD
}

_helper_run_each() {
	_SUB_FEATURE_NAME=${_FEATURE_NAME}_$(basename $_EXECUTOR | tr '[:lower:]' '[:upper:]' | tr '-' '_' | sed -e "s/\..*$//")

	_is_feature_enabled $_SUB_FEATURE_NAME || {
		unset _EXEC_CMD _SUB_FEATURE_NAME
		continue
	}

	_do_run
	unset _SUB_FEATURE_NAME
}

_do_run() {
	[ -n "$_NO_EXEC" ] && {
		unset _EXEC_CMD _EXEC_ALL_CMD _NO_EXEC
		return 1
	}

	if [ -n "$_SUPPORTS_CHANGED" ] && [ $_DEV_CHANGED -eq 1 ]; then
		_detail_action
		_exec_changed $_LANGUAGE
	else
		if [ -n "$_EXEC_ALL_CMD" ]; then
			$_EXEC_ALL_CMD
		else
			_detail_action
			_exec_all $_LANGUAGE
		fi
	fi

	unset _EXEC_CMD _EXEC_ALL_CMD _NO_EXEC
}

_detail_action() {
	[ -n "$_SUB_FEATURE_NAME" ] && _detail " $_SUB_FEATURE_NAME"
}

_helper_main() {
	for _LANGUAGE_PATH in $(find $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/$_ACTION -maxdepth 1 -type f); do
		. "$_LANGUAGE_PATH"
	done

	for _LANGUAGE_PATH in $(find $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/$_ACTION -maxdepth 1 -type d ! -name $_ACTION); do
		_LANGUAGE=$(basename $_LANGUAGE_PATH)
		if [ -e $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/language/$_LANGUAGE.sh ]; then
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/language/$_LANGUAGE.sh
		fi

		if [ $(_has_files $_LANGUAGE) -gt 0 ]; then
			_helper_run "$@"
		fi

		unset _EXTENSION
	done
}
