---
layout: post
title: "And this piece for you"
tags:
 -
---

If you remember last time we were in the spooky mansion of the evil toymaker,
cutting equivalent pieces of cake. We already have a way to generate adjacent
states to a given one and check for solutions, however we haven't yet explored
how to actually use these functions to iterate and solve the problem.

We first used best first to solve [the sliding tiles puzzle](
{% post_url 2014-01-22-the-sliding-tiles-puzzle %}) with great results, so let's try it
here:

~~~clojure
 (let [initial (build-initial-state 6 cake)
       solution? (build-solution-checker 6 cake)
       get-next-states (build-get-next-states 6 cake)]
    (bfser/solve initial solution? get-next-states))
~~~

Which arrives to the following solution in almost no time:

~~~clojure
[[3 8 8 8 7 6] 
 [3 3 3 8 7 6] 
 [4 4 3 8 7 6] 
 [4 4 4 7 7 6] 
 [5 5 5 5 5 6]]
~~~

However, let's remember for a moment something we said when we first
introduced best-first:

> Since we know that our solution must **lie somewhat close to the initial
> node** (It's unlikely that any game designer would be so evil to have us
> make hundreds of moves to solve the puzzle), our best bet is to use
> a breadth-first approach.

Does the solution for our current problem lie closer to the root node, or is
it nearer the leaves? Think about the tree we are generating, it starts with
all chunks being available for taking and in each level we add one chunk to
the active piece, until in the last level there are no available chunks, that
is, in the last level all the pieces are complete for every branch, or yet
again in other way, **all the solutions are in the last level!**.

Thinking about it this way exploring a full level before moving on to the next
seems like a waste. If we explore the tree in a depth-first manner, always
moving down before moving sideways, we'll probably find a solution sooner,
since we'll be getting to the last level of the tree regularly, while in
a breath-first solution we'll only get to the last level once we have explored
all the previous ones.

As for the implementation of a depth-first search, thanks to the magic arts of
recursion it's as simple as:

~~~clojure
(defn solve [state solution? get-next-states]
  (if (solution? state)
    [state]
    (if-let [states (some identity (map #(solve % solution? get-next-states) (get-next-states state)))]
      (conj states state))))
~~~

For consistency with the other solvers we are returning a list (a vector here)
with the history of all the states that lead to the solution, we don't need it
this time, but who knows what future puzzles we'll find in our quest?

The solution this solver comes up with is the same as the solution the
best-first provided, and since it's a pretty simple problem the difference in
execution time it's negligible, but for bigger cakes the best-first solver
would probably get stuck much sooner than the backtracker.
