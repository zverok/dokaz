# Dokaz

Dokaz (До́каз) means "proof" in Ukrainian.

**Dokaz** gem allows you to check all code inside your documentation, and
see what it outputs.

It just finds all pieces of <pre>```ruby</pre>-marked code in your .md
files, tries to run it and shows you the consequences.

## Install

Just as usual -- by adding `gem 'dokaz'` to your Gemfile then running
`bundle install`.

Or `[sudo] gem install dokaz`

## Usage

```
dokaz --help

Usage: dokaz [patterns] [options]

Patterns:
  File.md             one file
  File.md:15          only block around line 15
  folder/*.md         all files in folder

Options:
  -r, --require      Additional files to require, comma-separated
  -f, --format       Output format ("spec" or "show[case]")
      --help         Shows this message
```

Dokaz respects `.dokaz` file in local folder, which should be just its
options, each on newline.

## Output formats

* "spec" -- simple "does it work?" check:

* "showcase" or just "show" -- pretty copy-pasteable output of what
  sample code returns and prints:


You can just insert it back into your docs.

## Using it for your project's README

* Add to project's Gemfile (preferably to `:dev` group) `gem 'dokaz'`
* Create file for example `spec/dokaz_helpers.rb`, containing all
  initialization code to include your project files
* Create file `.dokaz`, containing:
```
README.md
--require ./spec/dokaz_helpers.rb
```
* Run `bundle exec dokaz`

## Using it for your project's GitHub wiki

* Do the same as above
* Clone your project's wiki to some directory (outside your project's directory!):
  `git clone git:github.com/myusername/myproject.wiki.git`
* At your project's directory, run `bundle exec dokaz /path/to/cloned/wiki/*.md`

## Known issues

* ridiculously simple, naïve and not tested; though, works for me;
* all code from all blocks is evaluated in same context (so, if block
  from one documentation file defines some class or variable, it is
  visible to all other blocks). Typically, it is reasonable behaviour,
  yet can produce unwanted effects when your docs demonstrate some
  metaprogramming or do some serious side-effects.

## License

MIT
