_cf_endpoint() {
	_CF_ENDPOINT=$(env | grep _CF_${_CF_ENVIRONMENT}_ENDPOINT= | sed -e 's/^.*=//')
	_require "$_CF_ENDPOINT" "_CF_ENDPOINT - $_CF_ENVIRONMENT (_CF_${_CF_ENVIRONMENT}_ENDPOINT)"
}

_cf_space_index() {
	_CF_SPACE_INDEX=$(env | grep _CF_${_CF_SPACE}_SPACE_INDEX= | sed -e 's/^.*=//')
	_require "$_CF_SPACE_INDEX" "_CF_SPACE - $_CF_SPACE_INDEX (_CF_${_CF_SPACE}_SPACE_INDEX)"
}
