# Log processing

* [Overview](#overview)
* [Project setup](#project-setup)
   * [`bats` acceptance tests](#bats-acceptance-tests)
   * [Working with the team repository](#working-with-the-team-repository)
   * [Directory structure](#directory-structure)
   * [Structure of HTML/JavaScript file](#structure-of-htmljavascript-file)
* [Outline of our solution](#the-outline-of-our-solution)
   * [Top-level `process_logs.sh`](#top-level-process_logssh)
   * [Write `process_client_logs.sh`](#write-process_client_logssh)
   * [Write `create_username_dist.sh`](#write-create_username_distsh)
   * [Write `create_hours_dist.sh`](#write-create_hours_distsh)
   * [Write `create_country_dist.sh`](#write-create_country_distsh)
   * [Write `assemble_report.sh`](#write-assemble_reportsh)
* [Final thoughts](#final-thoughts)
* [What to turn in](#what-to-turn-in)

## Overview

This lab is an example of a very common system administration task: Processing
log files. Most modern operating systems generate a *lot* of logging
information but, sadly, most of it is ignored, in part because of the huge
quantity generated. A common way of (partially) dealing with this mass of data 
is to write scripts that sift through the logs looking for particular
patterns and/or summarizing behaviors of interest. (This idea of using log analysis
for this lab was suggested by John Wagener, a UMM CSci alum who does this kind
of processing in his work in security analysis.)

In this lab we will be given a number of (old, from 2011) `secure` log files from several of
the lab machines. Our lab uses Redhat Linux and, at the time, essentially anything 
to do with authentication was stored in `/var/log/secure`.  Debian systems used 
a different, but similar file named `auth.log` and newer Linux systems using `systemd` require 
the use of a special command called `journalctl` to extract that same information.  However, 
even if the security information is not stored in one file, per se, the extracted data
has the same format as the old `/var/log/secure` files, so this type of processing remains relevant.

The `secure` files contain both successful and unsuccessful login
attempts.  We're going to focus on summarizing the unsuccessful login attempts,
most of which are clearly attempts by hackers to gain access through improperly
secured accounts. You'll write a collection of shell scripts that go through
each of the log files, extract the relevant information, and generate HTML and
JavaScript code that (via Google's chart tools) will generate graphs
showing:

* A <a href="http://code.google.com/apis/chart/interactive/docs/gallery/piechart.html">pie chart</a> showing the frequency of attacks on various user names.
* A <a href="https://developers.google.com/chart/interactive/docs/gallery/columnchart">column chart</a> showing the frequency of attacks during the hours of the day.
* A <a href="http://code.google.com/apis/chart/interactive/docs/gallery/geochart.html">GeoChart</a> showing the frequency of attacks by country of origin.

<a
href="http://www.morris.umn.edu/~mcphee/Courses/Examples/summary_plots.html">Go
here</a> to see what your graphs might look like.

Be warned, this is going to be a fairly complex lab with a lot of new
technologies, and for some may prove one of the most challenging labs of the
semester! Come prepared, work well together, work smart, and ask lots of
questions when you get stuck!

## Project setup

### `bats` acceptance tests

We've provided a collection of `bats` acceptance tests (the files ending in
`.bats` in `test`) for each of the scripts. You probably want to make sure
the tests for a helper script (e.g., `create_country_dist.sh`) pass before
you start working on a higher level script like `process_logs.sh`.

### Working with the team repository

When you accept the GitHub Classroom assignment you and your team-mates should have access to the same repository.
It's fine if both group members clone the the project but be sure to **commit often** and you might 
want to explore the use of `git pull` (or `git fetch` and `git merge`) to make sure everybody's
cloned repositories match.

### Directory structure

The repository that we give you contains log file data along with tests for each
of the scripts you need to write if you follow our outline solution below. The
directory structure we provide includes:

* `bin`: This is where you should put the shell scripts you write. The `bats`
   tests will assume your scripts are there (and executable) and will fail if
   they are not.
* `test`: This contains the `bats` tests you will be using to test each step
   of the lab. In theory you should not need to change anything in this
   directory. You are welcome to extend the tests, but please don't change
   them without reason.
* `log_files`: This has `tar` archives containing some old log files from
   several machines.
* `html_components`: This contains the headers and footers that wrap the
   contents of your data so Google magic can make pretty charts. You should not
   need to change anything in this directory, but your scripts will need to
   use things that are here.
* `etc`:  Contains miscellaneous files; currently the only thing here is a
   file that maps IP addresses to their hosting country. Again, you should not
   need to change anything here, but your scripts will need to use things that
   are here.
* `examples`: Contains some example files.

### Structure of HTML/JavaScript file

Based on the documentation and examples on the [Google
Chart](http://code.google.com/apis/chart/) site, our target HTML/JavaScript file
will have the structure like `examples/summary_plots.html` (look at the HTML in
an editor, or by viewing the source in your browser).  We've divided the example
HTML/JavaScript into several sections, each of which is labelled in that example
file:

* An overall header, which contains the opening HTML tags and loads the
  necessary JavaScript libraries from Google.
* A header for the section that defines the username pie chart. This
  includes the setting of a callback so that the function
  `drawUsernameDistribution()` gets called when the page loads, and the start
  of the definition of the function `drawUsernameDistribution()`.
* The actual username data, which is discussed in more detail below.
* A footer for the username graph section, which wraps up the definition
  of `drawUsernameDistribution()`.
* Similar header, data, and footer sections for the hours distribution column
  chart, defining the function `drawHoursDistribution()`.
* Similar header, data, and footer sections for the country distribution
  geo chart, defining the function `drawCountryDistribution()`.
* An overall footer, which finishes off the document.

You don't actually have to understand any of this HTML or JavaScript since all
you really need to do is pattern match. If, however, you run into a typo-induced
error or other snag, having some understanding of what's going on here will help
make debugging a lot simpler. So definitely look this over, ask questions, and
look things up.

As discussed in the
[prelab](https://github.com/UMM-CSci-Systems/Log-processing-pre-lab), this idea
of taking some text (e.g., the data for the username pie chart) and wrapping it
in a header and footer comes up so much in this lab that we pulled it out into a
separate script `wrap_contents.sh` which you wrote in the pre-lab. One of the
early activities of your group should be to compare notes on your different
solutions to `wrap_contents.sh` and pick one to be the one you'll use in this
lab. Place that script in your project's `bin` directory.

## The outline of our solution

### Overview

This is a fairly complex specification, so we're going to write several smaller
scripts that we can assemble to provide the desired functionality. Think of the
sub-scripts as being similar to functions (or even little classes) in a more
traditional programming environment. You can actually write functions in `bash`
scripts (the `bats` tests are functions), but we're choosing to break things up
into different scripts instead.

There are obviously many different ways to solve this problem, but we propose
the one described below and the tests are written assuming you organize your
solution this way as well.

### Top-level `process_logs.sh`

We'll start our description with a "top-level" script `process_logs.sh` which is
what you call to "run the program". This is _not_ where you should start the
programming, though, because this won't work until all the helper scripts are
written. So we'll describe it top-down, but you should probably write the
"helper" scripts (described below) first, and save `process_logs.sh` for last.

`process_logs.sh` takes a set of gzipped tar files on the command line, e.g.,

```bash
process_logs.sh this_secure.tgz that_secure.tgz...
```

where the files have the form `<machine name>_secure.tgz`. The 
file `toad_secure.tgz` would be a compressed `tar` archive containing 
the relevent log files from a machine named `toad`.

`process_logs.sh` then:

* Creates a temporary scratch directory to store all the intermediate files in.
* Loops over the compressed `tar` files provided on the command line,
  extracting the contents of each file we were given. See below for more
  info on the recommended file structure after extracting the log files.
  * The set of files to work with for the lab are in the `log_files`
    directory of your project.  
* Calls `process_client_logs.sh` on each client's set of logs to generate a
  set of temporary, intermediate files that are documented below. This needs to
  happen once for every set of client logs; you can just do it in the same
  loop that does the extraction above.
* Calls `create_username_dist.sh` which reads the intermediate files and
  generates the subset of an HTML/JavaScript document that uses Google's
  charting tools to create a pie chart showing the usernames with the most
  failed logins. This and the following steps only need to happen once, and thus
  should _not_ be in the extraction/processing loop.
* Calls `create_hours_dist.sh` which reads the intermediate files and
  generates the subset of an HTML/JavaScript document that uses Google's
  charting tools to create a column chart showing the hours of the day with
  the most failed logins.
* Calls `create_country_dist.sh` which reads the intermediate files and
  generates the subset of an HTML/JavaScript document that uses Google's
  charting tools to create a map chart showing the countries where most of
  the failed logins came from.
* Calls `assemble_report.sh` which pulls the results from the previous
  three scripts into a single HTML/JavaScript document that generates the
  three desired plots in a single page.
* Moves the resulting `failed_login_summary.html` file from the scratch
  directory back up to the directory where `process_logs.sh` was called.

Our solution extracts the contents of each archive into a directory (in the
scratch directory) with the same name as the client in the temporary
directory. Thus when you extract the contents of `toad_secure.tgz` you'd
want to put the results in a directory called `toad` in your scratch
directory. Having each in their own directory is important so you can
keep the logs from different machines from getting mixed up with each other.

As an example, assume:

* There are three log files for the machines `duck`, `goose`, and `toad`
* Each of which had five log files
* The temporary scratch directory is `/tmp/tmp_logs`.

Then, after extraction, `/tmp/tmp_logs` might look like:

```
/tmp/tmp_logs/
├── duck
│   └── var
│       └── log
│           ├── secure
│           ├── secure-20110723
│           ├── secure-20110730
│           ├── secure-20110805
│           └── secure-20110812
├── goose
│   └── var
│       └── log
│           ├── secure
│           ├── secure-20110717
│           ├── secure-20110803
│           ├── secure-20110807
│           └── secure-20110814
├── toad
│   └── var
│       └── log
│           ├── secure
│           ├── secure-20110724
│           ├── secure-20110731
│           ├── secure-20110807
│           └── secure-20110814
```

We'll use the `wrap_contents.sh` you wrote in [the
pre-lab](https://github.com/UMM-CSci-Systems/Log-processing-pre-lab) to simplify
the generation of the desired HTML/JavaScript documents.

We have `bats` tests for each of these shell scripts so you can do them one at
time (in the order that they're discussed below) and have some confidence that
you have one working before you move on to the next.

### Write `process_client_logs.sh`

This script takes a directory as a command line argument and does all its work
in that directory. That directory is assumed to contain the un-tarred and
un-gzipped log files for a _single_ client, but we don't know in advance how
many files there are or what they're called. The script `process_client_logs.sh`
will process those log files and generate an intermediate file called
`failed_login_data.txt` in that same directory having the following format:

```
Aug 14 06 admin 218.2.129.13
Aug 14 06 root 218.2.129.13
Aug 14 06 stud 218.2.129.13
Aug 14 06 trash 218.2.129.13
Aug 14 06 aaron 218.2.129.13
Aug 14 06 gt05 218.2.129.13
Aug 14 06 william 218.2.129.13
Aug 14 06 stephanie 218.2.129.13
Aug 14 06 root 218.2.129.13
```

The first three fields are the date and time of the failed login; the third
field is just the hour because we want to group the failed logins by hour, so
we'll just drop the minutes and seconds from the time. The fourth column is
the login name that was used in the failed login attempt. The fifth column is
the IP address the failed attempt came from. These five pieces of information
are enough to let us create the desired graphs.

A simple set of `bats` tests for this script are located in
`test/process_client_logs.bats`. To run them just type

```bash
bats test/process_client_logs.bats
```

in the top of your project directory.

The `secure` files contain a wide variety of entries documenting numerous
different events, but we only care about two particular kinds of lines. The
first is for failed login attempts on invalid usernames, i.e., names that aren't
actual user names in our lab, e.g.:

```
Aug 14 06:00:36 computer_name sshd[26795]: Failed password for invalid user admin from 218.2.129.13 port 59638 ssh2
Aug 14 06:00:55 computer_name sshd[26807]: Failed password for invalid user stud from 218.2.129.13 port 4182 ssh2
Aug 14 06:01:00 computer_name sshd[26809]: Failed password for invalid user trash from 218.2.129.13 port 7503 ssh2
Aug 14 06:01:04 computer_name sshd[26811]: Failed password for invalid user aaron from 218.2.129.13 port 9250 ssh2
```

The second is for failed login attempts on names that are actual user names in
the lab, e.g.:

```
Aug 14 06:00:41 computer_name sshd[26798]: Failed password for root from 218.2.129.13 port 62901 ssh2
Aug 14 06:01:29 computer_name sshd[26831]: Failed password for mcphee from 140.113.131.4 port 17537 ssh2
Aug 14 06:01:39 computer_name sshd[26835]: Failed password for root from 218.2.129.13 port 21275 ssh2
```

Thus the task for `process_client_logs.sh` is to take all the log files in the
specified directory, extract all the lines of the two forms illustrated above,
and extract the five columns we need. Our solution had the following steps, using
Unix pipes to take out output of one step and make it the input of the next step:

1. Move to the specified directory.
2. Gather the contents of all the log files in that directory and pipe
   them to a command that…
3. Extracts the appropriate columns from the relevant lines, piping them
   to a command that…
4. Removes the minutes and seconds from all the times, then…
5. Redirect the output to the file `failed_login_data.txt`.

We used plain old `cat` for step 2.

Step 3 is 90% of the work, and we used `awk` for that. (You could use a
combination of `grep` and `sed`, but `awk` can do it in one step.) You need two
different patterns to capture the two kinds of lines described above, and
because one is a subset of the other, it's important to include the negation of
the first test in the second or you'll end up with a bunch of double counting.
Also note that the columns to extract are different depending on which case
we're in.

You could do step 4 in `awk` as well (look up awk's `substr` function) and avoid
an additional pipe. Alternatively it's fairly straightforward to use `sed` for
step 4, using a substitution command that replaces the bits you don't want (the
hours and minutes) with nothing, effectively removing them. Either approach (or
any of several others not discussed here) is fine.

### Write `create_username_dist.sh`

The script `create_username_dist.sh` will take a single command line argument
that is the name of a directory. This is assumed to contain a set of
sub-directories (and nothing else), where the name of each sub-directory is the
name of one of the computers we got log information from, and each of these will
contain (possibly among other things) the file `failed_login_data.txt` created
by `process_client_logs.sh` as described above. It will then generate the
username distribution part of the HTML/JavaScript structure illustrated above,
placing the results in the file `username_dist.html` in the directory given on
the command line.

A simple set of `bats` tests for this script are located in
`test/create_username_dist.bats`. To run them just type

```bash
bats test/create_username_dist.bats
```

in the top of your project directory.

:warning: This script can and should assume that it's being called in your project
directory, so it can refer to the directory `html_components` which has the
header/footer files for this graph, namely
`html_components/username_dist_header.html` and
`html_components/username_dist_footer.html`. This means that if you want to just
call your script from the command line, you should do so from the top directory
of your project since that contains the directory `html_components`.

Writing this script essentially comes down to generating the necessary data for
the pie chart graph, and then wrapping it in the username distribution header
and footer using `wrap_contents.sh`. The key work, then, is the creation of the
data section from the summarized `failed_login_data.txt` files. We need to count
the number of occurrences of each of the usernames that appear in the
`failed_login_data.txt` files, and then turn those counts into the appropriate
JavaScript lines. For each username count, we need to add a row with that
information; this is accomplished with the line

```
data.addRow(['Hermione', 42]);
```

where the first argument to `addRow` is the username, and the second is the
number of failed logins on that username.

Gathering the contents of the `failed_login_data.txt` files and extracting the
username columns is quite similar to the start of `process_client_logs.sh`. Once
you have that, the trick is to figure out how to count how many times each
username appears. It turns out that the command `uniq` has a flag that counts
occurrances just as we need. The one trick is `uniq` needs its input to be
sorted; the command 'sort' will take care of this nicely. I then took the output
of `uniq` and ran it through a simple `awk` command that converted the output of
'uniq' into the desired `data.addRow` lines. I dumped that into a temporary
file, which I then handed to `wrap_contents.sh` to add the username header and
footer.

:ALERT: You may find you need to put a single quote (&apos;) inside an awk
command that is itself in single quotes. There are several ways to deal with
this, all of them apparently fairly ugly. One reasonable approach is to use

```
\x27
```

Backslash-x will, in the shell and actually in most programming languages let
you specify a character via the hexadecimal (hence the 'x' for 'hex') code for
that character. If you look at an ASCII table you'll find that single quote has
a hex code of 27. So a string like `"it\x27s"` will give you `"it's"`.

Note that you can test the file that this script generates by wrapping it with
the overall header and footer, and then loading it up in your browser. If all is
well, you should see a pie chart showing the distribution of usernames that were
attacked. Running it on its own requires that you have a directory with all the
right pieces in it, though, which isn't entirely trivial to set up. The body
of the `setup()` function in the `bats` test (`create_username_dist.bats`)
sets up exactly such a directory for the automatic tests, so you can use
that sequence of instructions to guide the construction of your own test
directory.

### Write `create_hours_dist.sh`

This is almost identical to `create_username_dist.sh` above, except that you
extract the hours column instead of the username column, and write the results
to the file `hours_dist.html`. The target lines will look something like:

```
data.addRow(['04', 87]);
```

where '04' is the hour and 87 is the number of failed login attempts that
happened in that hour. The hour is a two character string representing the hour
in military or 24-hour time, i.e., 10pm is '22'.

Again, a simple set of `bats` tests for this script are located in
`test/create_hours_dist.bats`. To run them just type

```bash
bats test/create_hours_dist.bats
```

in the top of your project directory.

Also, as before, you can test this by wrapping the resulting file with the
overall header and footer, and then loading it up in your browser. If all is
well, you should see a column chart showing the distribution of hours when
failed logins occurred. If you have a directory set up for hand testing as
discussed above in "Write `create_username_dist.sh`", you should be able to
use that here as well.

### Write `create_country_dist.sh`

The script `create_country_dist.sh` is extremely similar to
`create_username_dist.sh` above, with two exceptions. First, we're not counting
the occurrences of something we have in our dataset; we instead have to take the
IP addresses we do have, map them to countries, and then count the occurrences
of the resulting countries. Second, instead of plotting these on a pie chart,
we're going to use Google's Geo Chart to display the counts on a world map,
using different colors to indicate the counts.

Like the previous script, this too will take a single command line argument that
is the name of a directory. This is assumed to contain a set of sub-directories
(and nothing else), where the name of each sub-directory is the name of one of
the computers we got log information from, and each of these will contain the
file `failed_login_data.txt` created by `process_client_logs.sh` as described
above. It will then generate the country distribution part of the
HTML/JavaScript structure illustrated above, placing the results in the file
`country_dist.html` in the directory given on the command line.

This essentially comes down to generating the necessary data for the geo chart
graph, and then wrapping it in the country distribution header and footer using
`wrap_contents.sh`. The key work, then, is the creation of the data section from
the summarized `failed_login_data.txt` files. Here, however, we can't just count
occurrences of different IP addresses, we have to first map the IP addresses to
countries. There are a number of web services that will attempt (with
considerable success) to map IP addresses to locations. 
Rather than requiring that everyone sign up for such a service, we signed up
and created a file of IP addresses and countries for all
the IP addresses that appear in the data we're using here; we've provided that
in `etc/country_IP_map.txt`. You can then use this file to map IP addresses to
countries without having to sign up for some service.

The one interesting difference, then, between this and `create_username_dist.sh`
is the need to convert IP addresses into country codes. Assuming you've
extracted all the IP addresses (just like we extracted the usernames earlier),
then the command `join` (try `man join` for more) can be used to attach the
country code to each of the lines in your IP address file. :exclamation:
Sorting is really important for `join` to work correctly, so read the
documentation carefully and play with it by hand some so you understand how it
works.

After you've converted IP addresses to country codes, you can extract the
country codes, count their occurrences (like we counted usernames before), and
generate the necessary `data.addRow` lines, which again look like
`data.addRow(['04', 87]);`. Remember to then wrap those with the appropriate
header and footer, and you're done with this part.

Again, that you can test the output for this by wrapping it with the overall
header and footer, and then loading it up in your browser. If all is well, you
should see a geo chart showing the distribution of countries where attacks came
from. If you have a directory set up for hand testing as discussed above in the
previous two parts, you should be able to use that here as well.

### Write `assemble_report.sh`

Like the previous three scripts, this script again takes a directory name as its
sole command line argument. That directory is assumed to contain the three files
you've generated above:

* `username_dist.html`
* `hours_dist.html`
* `country_dist.html`

It collects together the contents of those files (we used `cat`) and then uses
`wrap_contents.sh` to add the overall HTML header and footer, writing the
results to `failed_login_summary.html` in your scratch directory.
If you open that file in a browser, you should see three cool
graphs like in the example above. If one or more of your graphs is missing or
blank, you might find it useful to open the JavaScript console in your browser
so you can see the error messages.

### Now write `process_logs.sh`

You now have all the pieces in place, and can go back and write [the
top-level `process_logs.sh` script](#top-level-process_logssh) that ties
everything together!

## Final thoughts

This is a large, complex lab. You learn a lot of cool stuff, and make
really nifty graphs, but there's definitely a lot of work involved. That said,
our solution is under 100 total lines, with comments. So if you find yourself
writing an epic novel of shell script commands, or are just stuck and beating
your head against the wall, you probably want to stop and ask some questions.

Commit early and often. Do this is bite-sized chunks, try stuff out in the shell
and then move that into your script when you've got it working. Commit again.
Ask more questions.

Our primary criteria here are, as always, correctness and clarity. When you get
the whole thing working and the `bats` tests passing, you can actually compare
your output against the source for the example given above and make sure you're
generating the same JavaScript that we did.

One additional thing we'll check for on this lab is that you clean up after
yourself. Our solution generated quite a lot of temporary directories and files,
and a well behaved script cleans up that sort of stuff when it's done. You
should never leave random files in the user's directories when they run a script
like this, and you should also clean up stuff that you dropped in places like
`/tmp` when you're done. Our tests can't easily check that you don't leave any
files anywhere, so you'll want to think about any temporary directories or files
you create and then go check by hand that your script removes them.

Note that "real" bash programmers probably wouldn't create this many helper
scripts, both for cultural reasons and because there is some overhead in having
one script call another instead of just staying in the original script. bash
scripting does allow for the definition of functions, which we could use to
provide this structure for our solution, but that introduces a new set of
complications, and it's tricky to test the functions independently using the
testing tools that we have. So we've chosen to do it this way for this lab.

Also, we _totally_ don't make any claims that this is the "best" way (whatever
that would mean), and we don't have any problems if you choose to blaze another
trail. We would, however, ask two things before you head off in a new direction.
First, make sure everyone in your group is cool with the decision to take a
different approach. It's a really _bad_ idea if one team member pushes the group
off in a direction only they really understand, as that really undermines
everyone else in the group and usually means that no one in the group learns
very much. So if you want to propose an alternative, especially a fairly
different one, think carefully about _why_ you're proposing it and what impact
that will have on the learning of the other people in your group. Similarly, if
someone in your group wants to dash off in a new direction, make sure you
understand what they're doing and make sure you agree that it's a good idea.
Make sure you stand up for your right to learn from this experience. One thing
we would _strongly_ recommend if you go this way is that the person that
proposed the new approach is _not_ allowed to drive. Having to explain their
ideas well enough that someone else can type them in and make them work helps
ensure that everyone "gets it", and if the proposer finds it frustrating to have
to explain themselves, then that's a _sure_ sign that switching to this new
approach was probably a bad idea.

## What to turn in

The `bin` folder in your finished project on Github folder should have the
following files:

* [ ] `assemble_report.sh`
* [ ] `create_country_dist.sh`
* [ ] `create_username_dist.sh`
* [ ] `create_hours_dist.sh`
* [ ] `process_client_logs.sh`
* [ ] `process_logs.sh`
* [ ] `wrap_contents.sh`

You shouldn't need to change anything in the other folders, but since your code
depends on them, you should leave them in your project repository for
completeness.

* [ ] Be sure to submit a link to your team's repository in Canvas!
