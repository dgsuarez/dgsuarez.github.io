---
layout: post
title: "Templating in bash"
tags:
 -
---

A templating language or library should be on the toolbox of every programming
environment. While mostly used in web development to output HTML, they are
useful in plenty other situations, from creating dynamic configuration files
to doing meta programming and preprocessing.

Today we are going to take a look at a couple of ways to do templates in bash,
half for fun and half because it's actually useful: creating a configuration
file with dynamic fields by running a simple script can be a pain without it.

m4 
--

If you google for bash templates, you'll eventually find
[m4](https://www.gnu.org/software/m4/m4.html). m4 is a pretty old school macro
preprocessor that has found it's way in the standard unix toolset, mostly due
to its use in autotools. It's mode of operation can be quite complex, with
directives to control output, rule rewriting, recursive looping... Have a look
at the [example on
wikipedia](http://en.wikipedia.org/wiki/M4_%28computer_language%29#Example)
for a small taste. This complexity mostly kills it for me, it seems that once
you start using m4 you are going to be in one of those _Now you have
2 problems_ scenarios.

However, if our templating needs are limited to some string substitutions, m4
can be a good option. With a template like this:

~~~
GREET, USER, your home is HOME
~~~

We can simply run `m4 -DUSER=$USER -DHOME=$HOME -DGREET=Hi template.m4` (careful
here, the order of the parameters is important, -DRULE declarations always go
before the template file) and get

~~~
Hi, diego, your home is /home/diego
~~~

sed
---

If we are limiting ourselves to simple substitutions we have at least to make
a passing mention of sed. Let's replicate the simple m4 example with sed. The
template is the same, and our command line would be something like this:

~~~
sed template.m4 -e "s/USER/$USER/g" -e "s/HOME/$HOME/g" -e "s/GREET/Hi/g" 
~~~

However using double quotes to allow for string evaluation of `$HOME` makes
the expression invalid, as after substitution it'll be `s/HOME/home/diego/g`.
We can avoid this error by changing the separator like this:

~~~
sed template.m4 -e "s/USER/$USER/g" -e "s|HOME|$HOME|g" -e "s/GREET/Hi/g" 
~~~

Which works, but we've arrived at a solution that is both more verbose and more
brittle when compared to the m4 one, while having no obvious benefits, 
so I think we can safely ignore sed for this use case.

cat, heredocs, and string interpolation
---------------------------------------

For now we are stuck with m4, which is very powerful but complex, and involves
learning a new language. Can't we simply use bash and have it work like PHP,
where plain strings are just outputted and code is executed and then
outputted? 

The best idea for this I've come up with is hackish, not as pretty
as a pure templating language, but it works. The idea is to use bash's string
interpolation to output environment variables that are passed to the template.
To output we'll use cat, and to provide multi line strings heredocs. Let's have
a look:

~~~
cat <<EOF
$GREET, $USER, your home is $HOME
EOF
~~~

This is our template, while there's a little bit of noise at the beginning and
end of it, it's mostly plain strings with the vars marked with `$` in front.
To run this template we can simply do this:

~~~
GREET=Hi . template.sh
~~~

More complex stuff is possible, but it may not be very pretty. For example
loops:

~~~
for i in {1..5}
do 
cat <<EOF
$GREET $USER
EOF
done

cat <<EOF
your home is $HOME
EOF
~~~

Which outputs 

~~~
Hi diego
Hi diego
Hi diego
Hi diego
Hi diego
your home is /home/diego
~~~

As I said, it's not the prettiest, and it's not quite the same as a pure
templating language since the primary mode of operation is execution + output,
not plain output, but for simple use cases, it can work pretty well.

Other options
-------------

So far I've tried to stay true to the standard unix toolbox, however since we
are in bash no one is preventing us from using PHP, or perl or ruby or
whatever. Setting up the environment for each template can be more complex,
but the power and simplicity they provide probably can't be matched by any of the options
we've talked about.
