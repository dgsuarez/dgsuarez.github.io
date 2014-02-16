---
layout: post
title: "The sliding tiles puzzle"
tags: adventure-puzzle-solver
 -
---

Let's start this series by solving one of the most frustrating and commonplace
puzzles in adventure games: [the sliding tile puzzle](http://en.wikipedia.org/wiki/Fifteen_puzzle).
It seems like at some point in half the games I've played the designer just
got lazy and included a 9x9, 8 tile puzzle, or even worse, [2 
side by side!](http://en.wikipedia.org/wiki/The_Whispered_World).

I've never got quite the hang of solving them manually, there are actually
rubick-cubesque instructions online with [methods for solving
them](http://www.the-spoiler.com/ADVENTURE/Future.games/nibiru.puzzles.1/Nibiru_SolvingSliders.htm). Our
solution however will be (at least initially) to brute-force it by generating
all the possible states the puzzle can be in and selecting a route from the
initial state of the puzzle to the solution state.

Let's get to it then. As an example we'll be using a puzzle we can find in
[Still Life](http://en.wikipedia.org/wiki/Still_Life_%28video_game%29). The
puzzle starts looking like
[this](http://www.adventurelantern.com/Walkthroughs/stillLife/18.jpg) and we
want it to look like
[this](http://www.adventurelantern.com/Walkthroughs/stillLife/19.jpg). We can
begin by representing this as states in our code. We will consider the
solution state to be _ordered_ and the initial _scrambled_:

```clojure
(def initial [[8 5 4]
              [2 0 6]
              [3 1 7]])

(def solution [[1 2 3]
               [4 0 5]
               [6 7 8]])
```

As you can see I'm using clojure here (bear in mind that I'm using these posts
as an exercise to learn the language, so many areas of the code may not be
idiomatic at all). What I did was assign each cell in the solution a number
starting in 1, leaving 0 for the empty space.

Now that we have a way of encoding states, and we know the initial and the
last, we need a couple of functions: one to check whether a given state is the
solution and another to get a list of the immediate moves or states for any
given state.

We'll start with the solution checker, in clojure this is very simple, we can do:

```clojure
(defn solution? [state]
  (= state solution))
```
or simply

```clojure
#{solution}
```

Next we need to generate the moves from a state. This isn't hard either, I'll
be using some helper functions you can see in the full
[repo](https://github.com/dgsuarez/adventure-puzzle-solver), but the gist of
it is:

```clojure
(defn free-cell [puzzle]
  (first (for [[x row] (map-indexed vector puzzle)
               y (range (count row))
               :when (= 0 (get-in puzzle [x y]))]
           [x y])))

(defn possible-next-steps [puzzle]
  (let [moves #{[-1 0] [1 0] [0 1] [0 -1]}
        [x y] (free-cell puzzle)
        new-coords (map (fn [[dx dy]] 
                          [(+ x dx) (+ y dy)]) moves)]
    (for [[nx ny] new-coords 
          :when (get-in puzzle [nx ny])] 
      (swap-cells puzzle [x y] [nx ny]))))

```

`free-cell` just returns the coordinates for the cell with value 0 (so, the
empty space) for a given state. `possible-next-steps` maps over the possible
directions (up, down, left and right) we may _move_ the empty space (that is,
move another tile into the empty space), and returns a list of all the valid
moves. So for example a puzzle like:

```clojure
[[1 2]
 [0 3]]
```

Will have as possible next steps the following states:

```clojure
[[0 2]
 [1 3]]
```
and

```clojure
[[2 0]
 [1 3]]
```

Now we have all the pieces necessary to break down this problem: A way of
knowing if we've reached a solution and a way of generating new states from
a given one. In the next post we'll look at how we can keep on iterating over
possible states until we find a path from the initial to the solution.

