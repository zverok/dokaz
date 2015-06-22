This file shows you how DocSpec work.

Try this
* `docspec examples/example.md`
* `docspec examples/example.md --format showcase`

## Example 1

So, lets begin with simple ruby code:

```ruby
1 + 18
```

In default (check) mode, this first gives just green dot (it works!).
In showcase mode you'll see what this code outputs; which allows you to
paste it into your docs.

## Example 2

This is more complex code, try it:

```ruby
class A
  def initialize(i)
    @i = i
  end

  def sum(other)
    @i + other
  end
end

a = A.new(5)
a.sum(3)
```

The code is evaluated in continuous manner, so, the `A` class and `a`
variable are already defined:

```ruby
a.sum(8)
```

This code not only returns values, but also outputs something to STDOUT:

```ruby
puts a.sum(10)
```

This code throws an error:

```ruby
# It's a comment, but not seen while evaluating
100 / 0
```

This code requires additional require:

```ruby
BigDecimal.new('0')
```

Try to run it with option `--require cgi`.
