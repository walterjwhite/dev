import git:install/teams.sh

_on_gh_open_pr_teams() {
	_require "$_CONF_DEV_GH_OPEN_PR_TEAMS_MESSAGE" _CONF_DEV_GH_OPEN_PR_TEAMS_MESSAGE
	_require "$_CONF_DEV_GH_OPEN_PR_WEBHOOK_URLS" _CONF_DEV_GH_OPEN_PR_WEBHOOK_URLS

	local teams_message=$(printf "$_CONF_DEV_GH_OPEN_PR_TEAMS_MESSAGE" "$_CONSOLE_CONTEXT_ID - $_CONSOLE_CONTEXT_DESCRIPTION" "$_PR_URL")
	_send_teams_message "$_CONF_DEV_GH_OPEN_PR_WEBHOOK_URLS" "$teams_message"
}
