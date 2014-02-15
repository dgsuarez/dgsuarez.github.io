---
layout: post
title: "Best-first: Cracking open the Grave Box"
tags:
 -
---

Last time we discovered that the breath-first search we had successfully used
for the sliding tiles puzzle was defeated by the more complex box found by
Sherlock Holmes. Since the naive strategy didn't work we'll have to look for
a more sophisticated one.

The problem with the breath-first algorithm is that it doesn't discriminate
between states, it just explores state after state without stopping to think
about how close to the solution each state is. Our new approach, best-first,
will try to address that by choosing the next state to explore with a little
more care.

Best-first is a class of algorithms, the most famous one being A\*. All of
them have in common that the next step is chosen according to a _fitness_ or
_scoring_ function that is applied to each state. Most implementations use
a priority queue to keep the states sorted. In short, the algorithm goes like
this:

* Pop a state from the queue and check if it is a solution. If it is then we
  are done, if it isn't then...
* Get the adjacent states from it, apply the scoring function to each and push
  them with the score as the priority into the queue
* Repeat

I won't go into much more detail about the actual implementation, you can look
it up in the repo. What's more interesting to me is the scoring function,
which will determine the success of the algorithm. 

Unlike the one-size-fits-all convenience of a simple search algorithm, here
we'll have to come up with a way of measuring how good a state is for each
problem that we tackle. A good scoring function will not only allow the
algorithm to finish fast, but also give us a reasonably short solution.

For the grave box puzzle we ended up with a representation of each state that
looked like this:

~~~clojure
(def state [[0 0 0 0 0 0 0 0 0]
            [2 6 3 7 5 4 4 8 0]
            [0 0 0 0 0 0 0 0 0]])
~~~

We want to have a measure of how close this is to a solution. One way would be
to check how far away each cell is from its final position, another, simpler
way is to just check how many cells are not yet in their final position. This
way the lower the score is, the closer we are to a solution. Also bear in mind
that we only care about the central row, the upper ones are just working
spaces and we can just ignore them when calculating a score.

~~~clojure
(defn compare-states [a b]
  (- (count (first a)) (count (filter identity (map = (get a 1) (get b 1))))))

(defn scorer [solution current]
  (compare-states solution (first current)))
~~~

In this implementation we are passing the function the current state along
with all the previous ones it took to get there, we'll see why in a bit. The
compare-states function simply counts how many columns there are in a state
and then subtracts from it the number of cells that are in place in the second
row.

We can now use this scoring function to try to get a solution to the grave box
problem, after 35 seconds in my rusty laptop we get a 215 steps long
solution. This length seems a little bit excessive, let's try to bring it
down.

The key to a shorter path is to improve our scoring function. We actually can
just use the length of the path as the score, this way the solution should be
of minimal length right?

~~~clojure
(defn scorer [solution current]
  (count current))
~~~

But wait a minute, if we sort the queue by path length, we are actually doing
a breath-first search! And like last time we tried it, my computer gets stuck
trying to reach a solution. 

So maybe we can try a combination of both measures, how far away is the
solution and how far we are from the initial state? This is actually what A\*
is all about, however for it to be A\* the scoring function must comply with
some restrictions that I haven't bothered to check for our scorer (although
I'm pretty certain that it doesn't meet), so we'll stick with calling it
best-first. 

The problem now is how to combine both measures, we can give them both equal
standing, for example by summing them, or we can give one priority over the
other, for example by returning them as a list. Let's try giving the length of
the path priority over the closeness to the solution:

~~~clojure
(defn scorer [solution current]
  [(count current) (compare-states solution (first current))])
~~~

And again, the computer gets stuck, let's try giving priority to the
closeness:

~~~clojure
(defn scorer [solution current]
  [(compare-states solution (first current)) (count current)])
~~~

In 45 seconds we get to a 115 steps long solution, 100 less than using just
the closeness. Just for the sake of completion let's try the equal comparator
to see how it goes:

~~~clojure
(defn scorer [solution current]
  (+ (compare-states solution (first current)) (count current)))
~~~

Again, stuck computer. This is probably due to the fact that our 
function measures differences in positions to get the closeness to the
solution while using path length to measure closeness to the start, that is,
we are combining apples with oranges. We could try to use a better heuristic
function, such as Manhattan distance, to see if it improves the speed and
length of the path, but for now I'm perfectly happy with the 115 steps.

