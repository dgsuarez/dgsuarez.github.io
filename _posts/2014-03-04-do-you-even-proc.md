---
layout: post
title: "Do you even proc?"
tags: ruby
---

One neat little feature in clojure is that sets and hashes can be used as
functions. While weird at first, it's actually pretty useful, more so when
combined with higher order functions like filter:

~~~clojure
(#{:a :b} :b); => :b
(#{:a :b} :c); => nil

({:a 1 :b 2} :a); => 1
({:a 1 :b 2} :c); => nil

(filter #{1 3} [1 2 3]); => (1 3)
~~~

I hadn't seen this data-structures-as-functions construct before, but I really
like it, it exploits the fact that there's a clear default action associated
with the type, looking up keys in a hash or elements in a set in the examples,
and uses it to make code both terser and more self-explanatory.

Actually, come to think about it, this is not as alien as it may seem. In ruby
we use `Symbol#to_proc` probably once every 5 lines. In fact we are so used to
it that we probably don't think much about what it **really** means:

~~~ruby
[1, 2, 3].inject(&:+)
~~~

What this code does is take the symbol `+`, and use the unary operator `&` to
call `to_proc` on it and 'turn' it into a block, which is then used as a block
for `inject`. The key thing to realize here is that we can provide a default
way for a type (`Symbol` in this case) to become a block, by using `&` and
`to_proc`. This does sound similar to what clojure is doing, doesn't it? It's
really just a matter of some monkeypatching to create hashes and sets that work
like functions:

~~~ruby
class Hash
  def to_proc
    Proc.new {|x| self[x]}
  end
end

class Set
  def to_proc
    Proc.new {|x| self.contains?(x) }
  end
end
~~~

Let's see how it works:

~~~ruby
[1, 2, 3].select(&Set.new(2)) # => [2]

h = {:a => 1, :b => 2, :c => 3}

[:a, :b, :c].map(&h) # => [1, 2, 3]
~~~

Again, while unfamiliar at first, the more I look at it the more I like it,
especially the hash example. Another type that has a well defined default
action is the regular expression:

~~~ruby
class Regexp
  def to_proc
    Proc.new {|x| x.match(self)}
  end
end
~~~

Which makes code like this possible:

~~~ruby
["a", "b", "c"].detect(&/a/) # => "a"

["a", "b", "c"].select(&/a/) # => ["a"]
# Note that this is the same as ["a", "b", "c"].grep(/a/)

["a", "b", "c"].reject(&/a/) # => ["b", "c"]
~~~

This one I like even better, it's much easier to spot when using literal
regexes and, as evidenced by the existence of `Enumerable#grep`, it's a pretty
useful feature.

`Array` may seem like another candidate, but what should the action be, look
up elements by position, or check for element presence?  Having to choose
probably means that it's better to leave it alone. As for others I can't
really think of more default types with action semantics clear enough to merit
a `to_proc` but I'd gladly hear any suggestions.

