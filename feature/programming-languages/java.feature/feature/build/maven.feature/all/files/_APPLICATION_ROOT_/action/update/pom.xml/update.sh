_info "Attempting to update dependencies"
mvn versions:use-latest-releases $_CONF_DEV_MAVEN_OPTIONS && gc -am 'updated dependencies' && gpush

