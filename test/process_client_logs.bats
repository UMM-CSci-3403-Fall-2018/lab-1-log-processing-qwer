#!/usr/bin/env bats

# Create a temporary scratch directory for the shell script to work in.
setup() {
  BATS_TMPDIR=`mktemp --directory`
  mkdir $BATS_TMPDIR/discovery
  tar -zxf log_files/discovery_secure.tgz --directory $BATS_TMPDIR/discovery
}

# Remove the temporary scratch directory to clean up after ourselves.
teardown() {
  rm -rf $BATS_TMPDIR
}

# If this test fails, your script file doesn't exist, or there's
# a typo in the name, or it's in the wrong directory, etc.
@test "bin/process_client_logs.sh exists" {
  [ -f "bin/process_client_logs.sh" ]
}

# If this test fails, your script isn't executable.
@test "bin/process_client_logs.sh is executable" {
  [ -x "bin/process_client_logs.sh" ]
}

# If this test fails, your script either didn't run at all, or it
# generated some sort of error when it ran.
@test "bin/process_client_logs.sh runs successfully" {
  run bin/process_client_logs.sh $BATS_TMPDIR/discovery
  [ "$status" -eq 0 ]
}

# If this test fails, your script didn't generate the correct output
# for the logs for discovery.
@test "bin/process_client_logs.sh generates correct simple output" {
  bin/process_client_logs.sh $BATS_TMPDIR/discovery
  sort $BATS_TMPDIR/discovery/failed_login_data.txt > $BATS_TMPDIR/discovery_sorted.txt
  sort test/discovery_failed_login_data.txt > $BATS_TMPDIR/test_sorted.txt
  run diff -wbB $BATS_TMPDIR/test_sorted.txt $BATS_TMPDIR/discovery_sorted.txt
  [ "$status" -eq 0 ]
}
