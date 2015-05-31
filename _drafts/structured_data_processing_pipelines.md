---
layout: post
title: "Structured data processing pipelines in sh"
tags:
 -
---

After a couple of coworkers asked me how I come up with long lines of bash
pipes to get data out of logs I started to try to come up with a good
explanation of my thought process. I think it boils down to:

* It's helpful to think of pipelines as having three basic steps: data
  retrieval => filtering => transforming => aggregating
* Pipelines work (for the most part) on **lists of text lines**. Most classic
  Unix command line tools are pure functions that take a list of lines as
  their input and output another list of strings `[String] => [String]`
* `xargs` is a poorly named `map` that works on other Unix tools

In this post I'll explore the retrieve => filter => transform => aggregate
pipeline, on the next one we'll take a deeper look at the `xargs` tool.

A tool for every season
-----------------------

Most pipelines have to do two things: get data out of somewhere and filter
and/or modify it in some way.

Let's start with retrieval. The most common sources of data in any system
are files: Logs, source code, data files... There are two basic scenarios:
Either you know which file has the data you are after, or you need to find it.

If you know where the data is then all you need to do is `cat`, `tail` or
`head` it (and yes, it's 99% likely that this starting `cat` useless and could
be replaced by a parameter to the next command, but it's also helpful to
understand the flow of the pipeline)

If not, then you are going to have to `find` it. `find` looks recursively in
a directory for files that match certain conditions. There are so many flags
to specify conditions that it'd be pointless to list them all here, I'll go
ahead with some examples, but if you are ever stuck on a situation like _How
can I get a list of the files modified by the www-user in the past week?_ just
`man find` or google it, some StackExchange site will probably have the flags
for you:

* `find` will list every file and directory in the current directory or its
  descendants
* `find -type f -name '*txt'` will list every file ending in txt, in the
  current directory or its descendants
* `find -mtime +7 -type d` will list every directory modified more than seven
  days ago in the current directory or its descendants
* ...

Once you have your data, you'll probably need to select only the bits you
want. The classic tool in this space is `grep`. Just a couple of notes:

* `grep -P` does perl compatible regexes instead of POSIX ones. If you are not
  getting the expected result out of your command, try setting it.
* `grep -v` inverts the output (shows lines that don't match)

Now you have the lines you want, but they may not be in the format you need.
It's time to transform using `sed` & `awk`.

`sed` does search & replace, if you use vim the syntax will feel right at
home:

* `sed 's/regex to replace/what to replace by/modifier'`

`awk` is, on itself, a fully featured programming language. At it's core It's
execution model is to read a list of text lines, and apply a function to each,
outputting the result. Here are the most basic uses of `awk`:

* `awk '{print $3}'` print the third field (default is separated by spaces or
  tabs) in each line
* `awk /Start/ {print $1, $NF}` print the first and last field of every line
  that matches the regex `/Start/`
* `awk -F ":" '{print $1 + $(NF-1)}'` print the sum of the first and second to
  last fields, using `:` as a field separator

Now for the last part, aggregating. There's a hodgepodge of tools for this,
some common ones that come to mind are:

* `sort -u` sort and keep only uniq lines
* `wc -l` count lines in the output
* `awk {sum+=$1} END {print sum}` sum the lines (as I said, `awk` is a fully
  featured programming language)

With this knowledge we can now create pretty complex pipelines, for example:

~~~bash

#Each line in log has a date, operation, object and elapsed time:
#2015-02-03 03:01:02 ADD USER oscar 0.00123s 

#Get the last time a user was added

cat mylog.log | grep 'ADD USER' | tail -n1

#Get all the users that were added

cat mylog.log | grep 'ADD USER' | awk '{print $(NF-1)}' | sort -u


#Getting the total time spent removing users
cat mylog.log | grep 'REMOVE USER' | awk '{print $NF}' | awk '{sum+=$1} END {print sum}'
~~~

This is probably what I'd write, it maps to the retrieve => filter =>
transform => aggregate pattern nicely, it's easy to just think about the step
you are writing and not care about the rest. However more experienced people
will recognize that most of them it can be done in just one `awk` command, for
example the last one:

~~~bash
awk '/REMOVE USER/ {sum += $NF} END {print sum}' mylog.log
~~~

That's it for now. As I said on the next post we'll explore `xargs`, which
will open up a new dimension for every step in the processing pipeline


