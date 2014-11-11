Rushed
=====
Ruby in your shell!

<img src="https://raw.github.com/tombenner/rushed/master/doc/logo.png" />

Overview
--------

Rushed brings Ruby's expressiveness, cleanliness, and readability to the command line.

It lets you avoid looking up pesky options in man pages and Googling how to write a transformation in bash that would take you approximately 1s to write in Ruby.

For example, to center a file's lines, use [String#center](http://ruby-doc.org/core-2.0/String.html#method-i-center):

```bash
ru 'map(:center, 80)' myfile
```

Using traditional tools, this isn't as easy or readable:

```bash
awk 'printf "%" int(40+length($0)/2) "s\n", $0' myfile
```

For another example, let's compare summing the lines of a list of integers using Rushed vs. a traditional approach:

```bash
ru 'map(:to_i).sum' myfile
```

```bash
awk '{s+=$1} END {print s}' myfile
```

Any method from Ruby Core and Active Support can be used. Rushed also provides some new methods to make transformations easier. Here are some variations on the above example:

```bash
ru 'map(:to_i, 10).sum' myfile
ru 'map(:to_i).reduce(&:+)' myfile
ru 'each_line.to_i.to_a.sum' myfile
ru 'grep(/^\d+$/).map(:to_i).sum' myfile
ru 'reduce(0) { |sum, n| sum + n.to_i }' myfile
ru 'each_line.match(/(\d+)/)[1].to_i.to_a.sum' myfile
```

See [Examples](#examples) and [Methods](#methods) for more.

Installation
------------

```bash
gem install rushed
```

You can now use Ruby in your shell!

For example, to sum a list of integers:

```bash
$ echo "2\n3" | ru 'map(:to_i).sum'
5
```

Usage
-----

See [Examples](#examples) below, too!

Rushed reads from stdin:

```bash
$ echo "2\n3" | ru 'map(:to_i).sum'
5
$ cat myfile | ru 'map(:to_i).sum'
5
```

Or from file(s):

```bash
$ ru 'map(:to_i).sum' myfile
5
$ ru 'map(:to_i).sum' myfile myfile
10
```

You can also run Ruby code without any input by prepending a `! `:

```bash
$ ru '! 2 + 3'
5
```

In addition to the methods provided by Ruby Core and Active Support, Rushed provides other methods for performing transformations, like `each_line`, `files`, and `grep`. See [Methods](#methods) for more.

Examples
--------

Let's compare the readability and conciseness of Rushed relative to existing tools:

#### Center lines

##### ru
```bash
ru 'map(:center, 80)' myfile
```

##### awk
```bash
awk 'printf "%" int(40+length($0)/2) "s\n", $0' myfile
```

##### sed
[Script](https://www.gnu.org/software/sed/manual/sed.html#Centering-lines)

#### Sum a list of integers

##### ru
```bash
ru 'map(:to_i).sum' myfile
```

##### awk
```bash
awk '{s+=$1} END {print s}' myfile
```

##### paste
```bash
paste -s -d+ myfile | bc
```

#### Print the 5th line

##### ru
```bash
ru '[4]' myfile
```

##### sed
```bash
sed '5q;d' myfile
```

#### Print all lines except the first and last

##### ru
```bash
ru '[1..-2]' myfile
```

##### sed
```bash
sed '1d;$d' myfile
```

#### Sort an Apache access log by response time (decreasing, with time prepended)

##### ru
```bash
ru 'map { |line| [line[/(\d+)( ".+"){2}$/, 1].to_i, line] }.sort.reverse.map(:join, " ")' access.log
```

##### awk
```bash
awk --re-interval '{ match($0, /(([^[:space:]]+|\[[^\]]+\]|"[^"]+")[[:space:]]+){7}/, m); print m[2], $0 }' access.log | sort -nk 1
```
[Source](https://coderwall.com/p/ueazhw)

Methods
-------

In addition to the methods provided by Ruby Core and Active Support, Rushed provides other methods for performing transformations.

#### each_line

Provides a shorthand for calling methods on each iteration of the input. Best explained by example:

```bash
ru 'each_line.strip.center(80)' myfile
```

If you'd like to transform it back into a list, call `to_a`:

```bash
ru 'each_line.strip.to_a.map(:center, 80)' myfile
```

#### files

Converts the lines to `Rushed::File` objects (see Rushed::File below).

```bash
$ echo "foo.txt" | ru 'files.map(:updated_at).map(:strftime, ""%Y-%m-%d")'
2014-11-08
```

#### format(format='l')

Formats a list of `Rushed::File`s. You'll typically call this after calling `files` to transform them into strings:

```bash
$ ru 'files.format'
644	tom	staff	3	2014-10-26	09:06	bar.txt
644	tom	staff	11	2014-11-04	08:29	foo.txt
```

The default format, `'l'`, is shown above. It prints `[omode, owner, group, size, date, name]`.

#### grep

Selects lines which match the given regex.

```bash
$ echo "john\npaul\ngeorge" | ru 'grep(/o[h|r]/)'
john
george
```

#### map

This is the same as `Array#map`, but it adds a new syntax that allows you to easily pass arguments to a method. For example:

```bash
$ echo "john\npaul" | ru 'map(:[], 0)'
j
p
$ echo "john\npaul" | ru 'map(:center, 8, ".")'
..john..
..paul..
```

Note that the examples above can also be performed with `each_line`:

```bash
$ echo "john\npaul" | ru 'each_line[0]'
$ echo "john\npaul" | ru 'each_line.center(8, ".")'
```

Rushed::File
------------

The [`files`](#files) method returns an enumerable of `Rushed::File`s, which are similar to Ruby Core's [`File`](http://ruby-doc.org/core-2.0/File.html). Each one has the following methods:

* `basename`
* `created_at` (alias for ctime)
* `ctime`
* `extname`
* `format` (see the [`format`](#formatformatl) method above)
* `ftype`
* `gid`
* `group`
* `mode`
* `mtime`
* `name` (alias for basename)
* `omode`
* `owner`
* `size`
* `to_s` (alias for name)
* `uid`
* `updated_at` (alias for mtime)
* `world_readable?`


Testing
-------

Nested Hstore is tested against ActiveRecord 3 and 4. If you'd like to submit a PR, please be sure to use [Appraisal](https://github.com/thoughtbot/appraisal) to test your changes in both contexts:

```bash
appraisal rspec
```

License
-------

Rushed is released under the MIT License. Please see the MIT-LICENSE file for details.
