# Dokaz

Dokaz (До́каз) means "proof" in Ukrainian.

**Dokaz** gem allows you to check all code inside your documentation, and
see what it outputs.

It just finds all pieces of <pre>```ruby</pre>-marked code in your .md
files, tries to run it and shows you the consequences.

## Usage

```
dokaz <files> <options>
```

## Output formats

* `--format spec` -- simple "does it work?" check:

* `--format showcase` -- pretty copy-pasteable output of what sample code
  returns and prints

## Using it for your project's README

## Using it for your project's GitHub Wiki

## Known issues

* ridiculously simple, naïve and not tested; though, works for me;
* all code from all blocks is evaluated in same context (so, if block
  from one documentation file defines some class or variable, it is
  visible to all other blocks). Typically, it is reasonable behaviour,
  yet can produce unwanted effects when your docs demonstrate some
  metaprogramming or do some serious side-effects.

## License

MIT
