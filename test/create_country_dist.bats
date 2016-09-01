#!/usr/bin/env bats

# Create a temporary scratch directory for the shell script to work in.
setup() {
  BATS_TMPDIR=`mktemp --directory`
  mkdir $BATS_TMPDIR/discovery
  mkdir $BATS_TMPDIR/velcro
  tar -zxf log_files/discovery_secure.tgz --directory $BATS_TMPDIR/discovery
  cp test/discovery_failed_login_data.txt $BATS_TMPDIR/discovery/failed_login_data.txt
  tar -zxf log_files/velcro_secure.tgz --directory $BATS_TMPDIR/velcro
  cp test/velcro_failed_login_data.txt $BATS_TMPDIR/velcro/failed_login_data.txt
}

# Remove the temporary scratch directory to clean up after ourselves.
teardown() {
  rm -rf $BATS_TMPDIR
}

# If this test fails, your script file doesn't exist, or there's
# a typo in the name, or it's in the wrong directory, etc.
@test "bin/create_country_dist.sh exists" {
  [ -f "bin/create_country_dist.sh" ]
}

# If this test fails, your script isn't executable.
@test "bin/create_country_dist.sh is executable" {
  [ -x "bin/create_country_dist.sh" ]
}

# If this test fails, your script either didn't run at all, or it
# generated some sort of error when it ran.
@test "bin/create_country_dist.sh runs successfully" {
  run bin/create_country_dist.sh $BATS_TMPDIR
  [ "$status" -eq 0 ]
}

# If this test fails, your script didn't generate the correct HTML
# for the bar chart for the hour data from discovery and velcro.
@test "bin/create_country_dist.sh generates correct simple output" {
  run bin/create_country_dist.sh $BATS_TMPDIR
  run diff -wbB test/country_dist.html $BATS_TMPDIR/country_dist.html
  [ "$status" -eq 0 ]
}
