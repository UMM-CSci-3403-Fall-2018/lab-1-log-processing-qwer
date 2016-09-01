#!/usr/bin/env bats

# Create a temporary scratch directory for the shell script to work in.
setup() {
  BATS_TMPDIR=`mktemp --directory`
}

# Remove the temporary scratch directory to clean up after ourselves.
teardown() {
  rm -rf $BATS_TMPDIR
}

# If this test fails, your script file doesn't exist, or there's
# a typo in the name, or it's in the wrong directory, etc.
@test "bin/wrap_contents.sh exists" {
  [ -f "bin/wrap_contents.sh" ]
}

# If this test fails, your script isn't executable.
@test "bin/wrap_contents.sh is executable" {
  [ -x "bin/wrap_contents.sh" ]
}

# If this test fails, your script either didn't run at all, or it
# generated some sort of error when it ran.
@test "bin/wrap_contents.sh runs successfully" {
  cd test/simple_wrap_contents_example
  run ../../bin/wrap_contents.sh test_middle.txt test_ends $BATS_TMPDIR/result.html
  [ "$status" -eq 0 ]
}

# If this test fails, your script didn't generate the correct output
# for test_middle.txt and test_ends. You probably want to run your
# script by hand and compare the results to the expected output
# in test_output.html.
@test "bin/wrap_contents.sh generates correct simple output" {
  cd test/simple_wrap_contents_example
  run ../../bin/wrap_contents.sh test_middle.txt test_ends $BATS_TMPDIR/result.html
  run diff -wbB test_output.html $BATS_TMPDIR/result.html
  [ "$status" -eq 0 ]
}

# If this test fails, your script didn't generate the correct output
# for the plotting example. You probably want to run your script by
# hand and compare the results to the expected output in
# chart_example/sample_chart.html
@test "bin/wrap_contents.sh generates correct plot output" {
  cd test/chart_wrap_contents_example
  ../../bin/wrap_contents.sh meats.txt bread $BATS_TMPDIR/chart_result.html
  run diff -wbB sample_chart.html $BATS_TMPDIR/chart_result.html
  [ "$status" -eq 0 ]
}
