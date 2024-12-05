#!/bin/sh

java -jar _LIBRARY_APPLICATION_PATH_/checkstyle/checkstyle.jar -c _LIBRARY_APPLICATION_PATH_/checkstyle/checks/${_CONF_DEV_CHECKSTYLE_VERSION_STYLE}_checks.xml "$@"
