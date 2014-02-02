---
layout: post
title: "Lazy breadth-first search"
---

In our previous post we created some functions to represent the sliding puzzle
game, now it's time to use them to finally solve it.  As I said before we are
not going to be subtle or particularly clever about it, we'll just walk over
the solution space until we find a path that connects the initial and solution
states. 

If that last paragraph was gibberish, think of it this way. Every time we
slide a tile in the puzzle, we are generating a new _state_. If we paint these
states on a piece of paper, and join them with lines, each line representing
the movement of a tile, we will get a graph. This graph is what I called the
_solution space_, and our task is to follow the lines from the initial state
to the solution.

Actually there are some nodes and vertices in the graph we don't care about,
we can limit the nodes to those we can get to by starting in the initial
state, and we can remove vertices to nodes that already have an incoming one,
removing loops. After these transformations we are left with a tree, which is
easier to work with.

There are a couple of basic ways to explore a tree, depth or breadth first. 
In a depth-first search (or backtracking), we'd explore the tree by picking
a child node, and then a child of the child, and so on, until we can go no
further, then we backtrack, and pick the next child, repeat, and so on until
we find the solution or run through the whole tree.  In a breadth-first search, 
we explore each child node before moving to the grandchildren, and we do this 
for every _level_ in the tree. 

Since we know that our solution must lie somewhat close to the initial node (I
don't think any game designer is so evil to have us make hundreds of moves in
an optimal solution to solve the sliding puzzle), our best bet is to use
a breadth-first approach.

Traditional implementations of breadth-first search use a queue to store the
nodes to explore, however, through the magic of lazy sequences we will be able
to create a simpler solution. In fact, here it is in under 20 lines of code:

~~~clojure
(defn all-next-for-path [path seen get-next-states]
  (for [s (get-next-states (first path)) :when (not (contains? @seen s))] 
    (do 
      (swap! seen conj s)
      (conj path s))))

(defn next-level [paths seen get-next-states]
  (mapcat #(all-next-for-path % seen get-next-states) paths))

(defn all-paths [paths seen get-next-states]
  (lazy-cat paths (all-paths (next-level paths seen get-next-states) seen get-next-states)))
            
(defn solve [state solution? get-next-states]
  (let [initial (list (list state))
        seen (atom #{})]
    (reverse (first (filter #(solution? (first %)) (all-paths initial seen get-next-states))))))
~~~

Let's look at this code starting from the top. `all-next-for-path` takes
a path (as a list of states) and gets all the possible steps from it. So if
we can move 3 tiles from the last state in the path, this will generate 3 new
paths by adding each tile move to the path. To avoid loops we are also passing
`seen`, which is a set of all the states we have already explored.

`next-level` uses `all-next-for-path` to generate all the possible n+1 length
paths from the list of paths it receives. `all-paths` can then recursively
call itself and use `next-level` to generate **all** the paths from it's
initial set of paths, one level down at a time. With this collection solving the
problem is as simple as getting elements from the collection until we find one
that is a solution. Also, since the collection is sorted by path length, we
know that the first path that is a solution is also one of the shortest.

I want to highlight a couple of things about this solution. The first one is
that this kind of solution is only possible because clojure can do lazy
sequences, `lazy-cat` won't eval its second argument until it exhausts the
first, so we are safe from stack overflows or infinite loops (that is, if the
puzzle we provide has a solution).

The second is that we are _cheating_ by using an `atom` to hold the set of
seen states. Atoms in clojure allow us to work with mutable state, and we are
changing it as we iterate. If we hadn't used it the simple `map` semantics in
`all-next-for-path` and `next-level` would have turned into a more cumbersome
`reduce` over two collections, the seen set and the paths.

Now we can finally solve the puzzle from Still Life. I won't print it here
because it's 27 steps long, but it is interesting that in my 6 year old laptop
it takes almost half a minute to come up with it, not great by any means, but
good enough, at least for now.
