---
layout: post
title: "The grave box puzzle"
tags:
 -
---

This time in our quest to solve the most annoying puzzles from adventure games
we will travel to 221B Baker Street in Victorian London, as Sherlock Holmes
unearths a locked box from a grave in [The Testament of Sherlock
Holmes](http://en.wikipedia.org/wiki/The_Testament_of_Sherlock_Holmes)

The lock mechanism consists of a sort of sliding puzzle, but this time the
tiles move in pairs. Rather than explaining it, it's easier to just [see it in
action](https://www.youtube.com/watch?v=I1kB0I5cHzI). 

Our first approach will be to use our breadth-first search implementation, so
we'll need the same functions we coded for the [sliding tiles
puzzle]({%post_url 2014-01-22-the-sliding-tiles-puzzle%}). Again, checking
we need both a initial and a solution state:

~~~clojure
(def start [[0 0 0 0 0 0 0 0 0]
            [2 6 3 7 5 4 4 8 0]
            [0 0 0 0 0 0 0 0 0]])

(def end   [[0 0 0 0 0 0 0 0 0]
            [7 8 2 3 5 4 6 4 0]
            [0 0 0 0 0 0 0 0 0]])
~~~

And a way to check if we are in a solution state:

~~~clojure
#{end}
~~~

We also need a `possible-next-states` function. Again, I'll be using some
helper functions that you can look up in the full repo, but the core is pretty
much similar to the one for the sliding puzzle:

~~~clojure
(defn possible-next-steps [puzzle]
  (for [move '([-1 0] [1 0] [0 1] [0 -1])
        pair (pairs puzzle)
        :let [from (pair-cells pair)
              to (pair-cells (new-pair pair move))]
        :when (valid-move? puzzle from to)]
    (move-cells puzzle from to)))
~~~

Great, now we can use our breath first searcher to do the heavy lifting:

~~~clojure
(bfser/solve start #{end} possible-next-steps)
~~~

We must be patient because this takes a long time. In fact, it takes such a long
time that I got tired of waiting before it came to a solution. Maybe Sherlock
won't be able to open the box just yet, but he shouldn't despair, next time
we'll be looking at a more efficient way of approaching the problem.


