pyrename
========

A port of the perl rename utility to Python, with extra features

The familiar perl-based [rename](http://plasmasturm.org/code/rename/)
is great, but I wanted to add a few additional features, and I hate
writing perl. Of course you can do almost anything you want with -e,
but that takes a perl expression. If you really want to, you can
write a script in your favorite language and --pipe to it, but do
that's a bit heavyweight for what's usually a one-off operation.

Usage
=====

`rename [SWITCHES|TRANSFORMS] [FILES]`

Use `rename -h` for full details.

Extra features
==============

`--stdin` and `FILES` are not incompatible; filenames from stdin
are inserted into `FILES` at the location of the `--stdin` switch.

The `--file` switch (which can be used multiple times)
similarly inserts filenames into the list by reading them from a
file.

Files can be sorted by atime, ctime, or birthtime, not just mtime.

The counter format can be just `...`, short for `...1`.

The counter is always present, even if you never use it.

You can rename `foo` to `Foo` even on case-preserving but
-independent filesystems.

A choice of different rename methods (`os.rename`, `os.replace`,
and `shutil.move`) are available (with different semantics for
overwriting target files and handling moves to different 
filesystems), along with `--copy` (in addition to the existing
`--symlink` and `--hardlink`).

Everything is Unicode-aware: `--nows` and `--noctrl`, `--subst` 
and `--re`, etc.

In addition to `--pipe`, you can also use `--echo` to pass the
name as a command-line argument instead of stdin.

Missing features
================

(Some of these will be added later.)

`--interactive` and `--force` are missing.

The Python `rename` script will happily overwrite anything that
the chosen rename method can handle, with no warning, rather than
checking whether the new name is available first.

Additional `--verbose` levels do nothing.

`--eval` is not implicit if no other transforms are given.

The `--transcode` option does not exist; it's assumed that Python
has read your filesystem encoding properly.

Feature differences
===================

For the most part, this script attempts to retain compatibility
with the similar Perl script, even down to things like `--symlink` 
to a different directory usuaslly giving you broken links. Most of 
the differences are down to the fact that both scripts provide a
way to evaluate code, and Perl and Python code are obviously not 
interchangeable.

Regular expressions are done with the `--re` or `--re-all` flag,
rather than just `--eval` with an `s//` or `s//g` expression 
(because Python has no such expression). And of course they use 
Python regexp syntax, which is slightly different from Perl's. 
In many simple cases, the `--sed` switch can be used as a drop-in
replacement for Perl `--eval`, because its `s//` command is 
basically the same, except with a very different regexp syntax.)

`--eval` takes a Python expression, rather than perl. The
original name is available as `name`, rather than `$0`, any
extensions popped by -X are available as `ext` and `exts` 
rather than `$EXT` and `@EXT`, and the formatted counter as `n`
rather than `$N`.

`--stdin` does not do the same thing, and `--nostdin` does not
exist.

Examples
========

Most of the examples from the TUTORIAL and COOKBOOK sections of
the Perl `rename` tool will work, but those that use `--eval`
of course need to be modified. For example:

    rename -p -c -z -X -e '$_ = "$EXT/$_" if @EXT' *
    
    rename -p -c -z -X -e 'ext+'/'+name if ext else name' *

Also, the example using `-T` together wit the `Text::Unidecode`
obviously can't be done, but if you're just looking to replace
all non-Latin-1 characters, that's easy:

    rename -T utf8 -MText::Unidecode '$_ = unidecode $_' *
    
    rename -e 's.encode("latin-1", "replace").decode("latin-1") *

See the `tests.sh` script for additional examples.
