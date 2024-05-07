#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  export LW_API_KEY='API_KEY'
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR=LWINTERI_0A741CAFFB4878ABB99B1553E8A2FD114E99732BA9FCEE9
  export BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR=_8994f928a48b3a2aa9971fd81079224a
  export BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME='lwinterikwennerberg'
  export BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'
}

@test 'Default API key environment variable is used' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR
  stub lacework "echo called with params \$@"
  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial '--api_key LW_API_KEY'
  
  unstub lacework
}


@test 'Missing default API key environment variable' {
  unset LW_API_KEY
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR

  run "${PWD}"/hooks/command

  assert_failure
  assert_output --partial 'unbound variable'
}

@test "Error if no account name was set" {
  unset BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME
  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "ERROR: Missing required config 'account-name'"
}

@test 'Missing API key secret environment variable' {
  unset BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR
  export LW_API_SECRET='API_KEY_SECRET'
  stub lacework "echo called with params \$@"
  run "${PWD}"/hooks/command

  assert_success
  assert_output --partial '--api_secret LW_API_SECRET'
  
  unstub lacework
}


@test 'Lacework SCA SCAN' {

  BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE='sca'

  run "${PWD}"/hooks/command

  assert_success
  
  unstub lacework
}
