fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
description 'A framework for RedM'
author 'Homestead VORP Dee'

server_scripts {
    'server/*'
}

files {
    "shared/jobs.json",
    "shared/businesses.json"
}

server_exports {
    "validateJob",
    "validate_job_cb"
}