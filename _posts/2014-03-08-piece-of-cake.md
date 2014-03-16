---
layout: post
title: "Piece of cake"
tags:
 -
---

What would you expect if an evil toy maker invited you and six other random
third rate actors to spend a night in a campy early-nineties CGI haunted house
for the chance to win a fortune? The answer is obvious: horror themed logic
puzzles!

Let's delve into 1993's [the 7th
Guest](http://en.wikipedia.org/wiki/7th_Guest) (now playable almost anywhere
with [ScummVM](http://scummvm.org)), a series of puzzles barely held together
by a "horror" storyline.  One of the first puzzles we'll have to solve
involves
a [cake](http://www.mobygames.com/images/shots/l/343866-the-7th-guest-dos-screenshot-cake-puzzles.png)
with skull, tombstone and plain toppings, which we will have to cut into six
pieces with the same type and number of toppings.

Let's start by getting a representation for the cake, I don't think anyone
will be surprised when we turn to our trusty matrix, with 1s being skulls, 2s
tombstones and 0s plains:

~~~clojure
(def cake [[1 2 2 1 2 1]
           [0 2 1 1 2 1] 
           [0 2 2 0 1 0]
           [1 1 2 0 1 2]
           [2 2 1 0 1 2]])
~~~

For the solution, we can use numbers from 3 to 8 to represent each of the
pieces, so this would be one of the multiple solutions:

~~~clojure
(def solution [[3 8 8 8 7 6] 
               [3 3 3 8 7 6] 
               [4 4 3 8 7 6] 
               [4 4 4 7 7 6] 
               [5 5 5 5 5 6]])
~~~

As you can see each piece has 2 skulls, 2 tombstones and a plain topping. For
starters, we need to get the number of each type of topping that a piece will
have, something like this:

~~~clojure 
{0 1, 1 2, 2 2}
~~~

Starting from the cake and the number of pieces we want to make, here's a way
of getting this _piece spec_

~~~clojure
(defn get-spec [pieces cake]
  (into {} (map #(vector (first %) (-> % last count (/ pieces))) 
                (group-by identity (flatten cake)))))
~~~

Basically we group the toppings, count them and divide by the number of pieces
for each, creating a hash with the result. With this spec it now becomes
easier to think about how we are going to solve the puzzle. Starting from
a fixed position, in each iteration we are going to add a chunk to a piece,
making sure that it conforms to the spec. 

For the next iteration the cake will have one less available chunk (the one we
added to the piece) and the spec will reflect that it needs one less of the
topping we added. Once a piece is complete, we'll reset the spec to start
creating a new piece.

The following piece of code updates all these parts. Note that we are using
a map to store all the different pieces of information and moving them around,
and we are merging it with the updated versions of each of them: 

  * The cake with the piece updated.
  * The spec with one less of the taken topping
  * The position in the cake we have just updated, so that in the next
    iteration we now where to start from

~~~clojure
(defn update-position [pos state]
  (let [{:keys [cake piece-num spec]} state]
    (merge state {:cake (assoc-in cake pos piece-num)
                  :last-pos pos
                  :spec (update-in spec [(get-in cake pos)] dec)})))
~~~

With this the next part should be pretty familiar for us, from a position we
gather all the adjacent chunks that could be added to the current piece and
return a list of these new states:

~~~clojure
(defn valid-next [{:keys [last-pos spec cake]}]
  (filter #(valid-val? (spec (get-in cake %)))
          (for [coord [[-1 0] [0 -1] [1 0] [0 1]]] 
            (map + last-pos coord))))

(defn get-next-states [original-state state]
  (let [state (update-spec original-state state)]
    (map #(update-position % state) (valid-next state))))
~~~

Next up, we need a way of checking for solutions. One way would be to check
that each piece conforms to the spec, however, since we are ensuring that each
piece conforms while we are creating it, checking for the solution is as
simple as ensuring that there are no toppings left on it:

~~~clojure
(defn solution? [{piece-num :piece-num} state]
  (every? #(>= % piece-num) (flatten (:cake state))))
~~~

We are almost done, if you check the
[repo](https://github.com/dgsuarez/adventure-puzzle-solver/blob/master/src/adventure_puzzle_solver/seventh_cake.clj)
you'll see some more functions that, given a cake and a number of pieces
create the map we use to iterate and curry the `solution?` and
`get-next-states` functions so that they can be used in our solvers. 

I think we've had enough cake for one sitting, come back next time to see how
our generic solvers fare when confronted with this sweet problem.
