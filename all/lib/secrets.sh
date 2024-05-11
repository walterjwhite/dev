_run_init_secrets() {
	if [ -e .secrets ]; then
		_info "Copying secrets -> $_RUN_INSTANCE_DIR"
		cp -R .secrets/* $_RUN_INSTANCE_DIR
	fi
}

_find_secrets() {
	[ ! -e .secrets ] && return 1


	local find_secret_patterns=$(cat .secrets | sed -e "s/^/\-iname \"/" -e 's/$/"/' | tr '\n' ' ')
	find . \(! -path '*/.git/*' ! -path '*/target/*' ! -path '*/.log/*' ! -path '*/*.secret/*' ! -name '*.secret' ! -name '*.iml' \) -and \( $find_secret_patterns \)

	local grep_secret_patterns=$(cat .secrets | tr '\n' '|' | sed -e 's/|$//')
	find . -type f \(! -path '*/.git/*' ! -path '*/target/*' ! -path '*/.log/*' ! -path '*/*.secret/*' ! -name '*.secret' ! -name '*.iml'\) \
		-exec $_CONF_INSTALL_GNU_GREP -i "($grep_secret_patterns)" {} +
}
