#compdef jira-terminal

autoload -U is-at-least

_jira-terminal() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_jira-terminal_commands" \
"*::: :->JIRA Terminal" \
&& ret=0
    case $state in
    (JIRA Terminal)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:jira-terminal-command-$line[1]:"
        case $line[1] in
            (transition)
_arguments "${_arguments_options[@]}" \
'-t+[Ticket ID from JIRA.]' \
'--ticket=[Ticket ID from JIRA.]' \
'-l[List the possible transitions.]' \
'--list[List the possible transitions.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':STATUS -- Status or alias of status to move the ticket to.:_files' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" \
'*-p+[Project Code to filter with.]' \
'*--project=[Project Code to filter with.]' \
'*-a+[Assignee username or email to filter with.]' \
'*--assignee=[Assignee username or email to filter with.]' \
'*-c+[Component name or ID to filter with.]' \
'*--component=[Component name or ID to filter with.]' \
'-d+[]' \
'--display=[]' \
'*-e+[EPIC name or issue key of epic to filter with.]' \
'*--epic=[EPIC name or issue key of epic to filter with.]' \
'*-f+[Filter name or filter id that you saved in JIRA.]' \
'*--filter=[Filter name or filter id that you saved in JIRA.]' \
'-j+[JQL Query or alias to JQL query to filter with.]' \
'--jql=[JQL Query or alias to JQL query to filter with.]' \
'*-l+[Search for issues with a label or list of labels.]' \
'*--label=[Search for issues with a label or list of labels.]' \
'*-m+[Search for subtask of a particular issue.]' \
'*--main=[Search for subtask of a particular issue.]' \
'*-P+[Search for issues with a particular priority.]' \
'*--priority=[Search for issues with a particular priority.]' \
'*-r+[Search for issues that were reported by a particular user.]' \
'*--reporter=[Search for issues that were reported by a particular user.]' \
'*-s+[Search for issues that are assigned to a particular sprint.]' \
'*--sprint=[Search for issues that are assigned to a particular sprint.]' \
'*-S+[Search for issues that have a particular status.]' \
'*--status=[Search for issues that have a particular status.]' \
'*-t+[Search for issues that have a particular issue type. ]' \
'*--type=[Search for issues that have a particular issue type. ]' \
'-T+[This is a master-field that allows you to search all text fields for issues.]' \
'--text=[This is a master-field that allows you to search all text fields for issues.]' \
'-C+[Total number of issues to show. (Default is 50)]' \
'--count=[Total number of issues to show. (Default is 50)]' \
'-o+[Offset to start the first item to return in a page of results. (Default is 0)]' \
'--offset=[Offset to start the first item to return in a page of results. (Default is 0)]' \
'-A+[Save the applied options as an alias. You can use it with jql option later.]' \
'--alias=[Save the applied options as an alias. You can use it with jql option later.]' \
'-M[Issues assigned to you.]' \
'--me[Issues assigned to you.]' \
'-J[JSON response]' \
'--json[JSON response]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(detail)
_arguments "${_arguments_options[@]}" \
'-f+[]' \
'--fields=[]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':TICKET -- Ticket id for details.:_files' \
&& ret=0
;;
(alias)
_arguments "${_arguments_options[@]}" \
'(-l --list -r --remove)-a+[Value to associate with provided alias name.]' \
'(-l --list -r --remove)--add=[Value to associate with provided alias name.]' \
'(-a --add -r --remove)-l[List the alias saved.]' \
'(-a --add -r --remove)--list[List the alias saved.]' \
'(-l --list -a --add)-r[List the alias saved.]' \
'(-l --list -a --add)--remove[List the alias saved.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':NAME -- Name of alias. (Required except for list option):_files' \
&& ret=0
;;
(fields)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':TICKET -- Ticket id for details.:_files' \
&& ret=0
;;
(assign)
_arguments "${_arguments_options[@]}" \
'-u+[Assign the ticket to the provided user.]' \
'--user=[Assign the ticket to the provided user.]' \
'-t+[Ticket to use.]' \
'--ticket=[Ticket to use.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(comment)
_arguments "${_arguments_options[@]}" \
'-b+[Body of the comment. To mention someone, you can use @(query) The query can include jira username or display name or email address.]' \
'--body=[Body of the comment. To mention someone, you can use @(query) The query can include jira username or display name or email address.]' \
'-t+[Ticket to use.]' \
'--ticket=[Ticket to use.]' \
'(-b --body)-l[List all the comments of a ticket.]' \
'(-b --body)--list[List all the comments of a ticket.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" \
'-f+[Key of field to update. You can use jira-terminal fields <TICKET> to see possible set of keys.]' \
'--field=[Key of field to update. You can use jira-terminal fields <TICKET> to see possible set of keys.]' \
'-v+[Value of the field to update.]' \
'--value=[Value of the field to update.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':TICKET -- Ticket ID to update:_files' \
&& ret=0
;;
(autocompletion)
_arguments "${_arguments_options[@]}" \
'-s+[]' \
'--shell=[]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" \
'(-m --main)-P+[Project Key to create the ticket.]' \
'(-m --main)--project=[Project Key to create the ticket.]' \
'(-P --project)-m+[Main ticket to create the sub-ticket.]' \
'(-P --project)--main=[Main ticket to create the sub-ticket.]' \
'-t+[Issue type for new ticket.]' \
'--type=[Issue type for new ticket.]' \
'-l+[Comma separated list of labels.]' \
'--labels=[Comma separated list of labels.]' \
'-p+[Priority Of the ticket.]' \
'--priority=[Priority Of the ticket.]' \
'-s+[Summary of ticket]' \
'--summary=[Summary of ticket]' \
'-d+[Description of ticket]' \
'--description=[Description of ticket]' \
'-c+[Comma separated list of components of ticket]' \
'--components=[Comma separated list of components of ticket]' \
'-a+[Assignee email of ticket]' \
'--assignee=[Assignee email of ticket]' \
'-C+[Comma separated value pair for custom fields. You can use alias in value or key itself. Example- "customfield_12305:value,alias_to_key:value2. You can use fields subcommand to check the list of custom fields available. ]' \
'--custom=[Comma separated value pair for custom fields. You can use alias in value or key itself. Example- "customfield_12305:value,alias_to_key:value2. You can use fields subcommand to check the list of custom fields available. ]' \
'-M[Only summary and description will be asked if not available.]' \
'--minimal[Only summary and description will be asked if not available.]' \
'-q[Do not ask for missing options.]' \
'--quiet[Do not ask for missing options.]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
}

(( $+functions[_jira-terminal_commands] )) ||
_jira-terminal_commands() {
    local commands; commands=(
        "transition:Transition of ticket across status." \
"list:List the issues from JIRA." \
"detail:Detail of a JIRA tickets.." \
"alias:Configuration for alias. One of add,list or remove is required." \
"fields:List of possible Fields for details..." \
"assign:Assign a ticket to user." \
"comment:List or add comments to a ticket. Default action is adding." \
"update:Update a field for a ticket" \
"autocompletion:Generate autocompletion script.." \
"new:Create a new ticket." \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'jira-terminal commands' commands "$@"
}
(( $+functions[_jira-terminal__alias_commands] )) ||
_jira-terminal__alias_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal alias commands' commands "$@"
}
(( $+functions[_jira-terminal__assign_commands] )) ||
_jira-terminal__assign_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal assign commands' commands "$@"
}
(( $+functions[_jira-terminal__autocompletion_commands] )) ||
_jira-terminal__autocompletion_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal autocompletion commands' commands "$@"
}
(( $+functions[_jira-terminal__comment_commands] )) ||
_jira-terminal__comment_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal comment commands' commands "$@"
}
(( $+functions[_jira-terminal__detail_commands] )) ||
_jira-terminal__detail_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal detail commands' commands "$@"
}
(( $+functions[_jira-terminal__fields_commands] )) ||
_jira-terminal__fields_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal fields commands' commands "$@"
}
(( $+functions[_jira-terminal__help_commands] )) ||
_jira-terminal__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal help commands' commands "$@"
}
(( $+functions[_jira-terminal__list_commands] )) ||
_jira-terminal__list_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal list commands' commands "$@"
}
(( $+functions[_jira-terminal__new_commands] )) ||
_jira-terminal__new_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal new commands' commands "$@"
}
(( $+functions[_jira-terminal__transition_commands] )) ||
_jira-terminal__transition_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal transition commands' commands "$@"
}
(( $+functions[_jira-terminal__update_commands] )) ||
_jira-terminal__update_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'jira-terminal update commands' commands "$@"
}

_jira-terminal "$@"
