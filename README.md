The One True Makefile
=====================

The purpose of this One True Makefile project is to provide a template
for projects that use Autoconf, Libtool and Make, but not Automake.
(I prefer not to use Automake, although obviously I like some of its
brothers.)  It is placed in the public domain, since I don't see the
point of making a copyleft build process template.

If you're going to use this template project, you will probably want
to already have a working knowledge of how Autoconf, Libtool and Make
work, although if you're still learning, you might like to use the One
True Makefile as a working example.  (This README won't be much of a
tutorial, though.)  In order to understand the logic of e.g. what goes
in `share` directories and what goes in `etc` directories, you should
probably also have a basic familiarity with the Linux Filesystem
Hierarchy Standard.

Rules are set up with C++ in mind, although it should be easy to add
rules for other languages.

Features
========

The One True Makefile's build philosophy is based on the one from
Peter Miller's "Recursive Make Considered Harmful" paper, although it
also has some other nice features.  Specifically, the One True
Makefile provides:

1. Modularity.

2. Incremental builds.  Make knows about all the dependencies, so
    everything Just Works with a minimum of compiling.  There is no
    need to run `make clean` every single compilation cycle.

3. Automatic `#include` directive dependency generation.  (You need to
    have a compiler that accepts the `-MM` flag, like gcc.)  However,
    please note that there's no way for the computer to know that
    e.g. your foo program depends on the baz module, and also on
    libz.so, so you still have to manually specify library
    dependencies and link targets in the module.mk files.

4. Avoidence of recursive Make.  (See Miller's paper; it's easy to
    find with google.)

5. Parallel building using Make's `-j` flag.  This is robust and works
    well with incremental builds thanks to point 4).

6. Unit tests, build artifacts, and final output all go in their own
    dynamically-generated subdirectories.  Because of Libtool, you can
    run executables in the final output (staging) directory in-place,
    and shared libraries will Just Work, even if you haven't run make
    install.

7. A `make uninstall` target.  (I wish more autotools-based projects
    provided that.)

8. A unit testing framework that leverages Python's unittest library.
    (Yes, unittest is designed for Python projects, but it's pretty
    trivial to use the subprocess module to wrap C and/or C++
    programs, and Python is a nice "glue" language to use if your
    testing process gets sophisticated.  For example, you may want to
    start doing things like starting multiple services before running
    for a single test, and stopping them afterward, and Python's
    `unittest` framework provides hooks for that.)

9. Flexibility, in that I've tried to write everything in such a way
    that, if you don't like what the One True Makefile is doing
    (blasphemer!), it should be obvious how it works and how you can
    change it.

10. I've included a copy of Lee Thomason's excellent TinyXML2 library,
    since I like using xml for config files.  If you don't like and/or
    need it, removing it is as easy as removing `tinyxml2` from the
    modules section of `Makefile.in`, and running `rm -rf tinyxml2`.
    (This is an example of the modularity of which I spoke, up in
    point 1).)  Note that the actual library will be called
    `libtinyxml2-otm.so`, with a `-otm` at the end, in order to avoid
    conflicts with any other `libtinyxml2.so` shared library files
    that may be installed.  (Again, if you don't like the `-otm`
    suffix, it's easy to change; in fact, you should probably change
    that suffix to something that calls to mind the name of your
    project.)

Note that I have tried to provide the above benefits using minimalist
approaches; for example, I use implicit rules whenever possible.  This
makes the build machinery more readable, easier to understand and
easier to maintain.  If you feel overwhelmed reading the Makefile.in,
I highly recommend reading the Recursive Make Considered Harmful paper
by Miller.  It's easy to find via Google.

Scheme for `#include` directives
================================

Please note that, if your project provides e.g. a
`MyProject::Foo::Foodle` class, then you should specify its interface
with an `#include` directive that mirrors the namespace hierarchy,
like so:

    #include "MyProject/Foo/Foodle.h"

Thus, if the interface file is going to end up installed in a normal
way, at `/usr/local/include/MyProject/Foo/Foodle.h`, then the people
who use your library only have to give the compiler a
`-I/usr/local/include` flag, and in fact compilers usually already
have that path specified by default, so your users actually don't have
to do anything.  The `#include` directives mirror the namespace, and
compiling Just Works.

Please note that some people use a dirty scheme whereby their include
directive for a file installed somewhere like
`/usr/local/include/MyProject/Foo/Foodle.h` looks like this:

    #include "Foodle.h" // Bad!

This means that their users have to pass the compiler a
`-I/usr/local/include/MyProject/Foo` flag, since the compiler doesn't
know about the MyProject/Foo subdirectory by default.  In fact, the
user has to include another compiler flag for every dependency that
does this.

But you don't do that, because you're better than that.

(Please note that my rant is somewhat spoiled by the fact that the
included copy of TinyXML2 (by Lee Thomason) does not use this
project's namespace (i.e. something like
`OneTrueMakefile::TinyXML2::TiXmlDocument`), since I didn't write the
(excellent) TinyXML2 library, and instead I just dropped it into this
One True Makefile project.  I didn't change how namespaces work in
TinyXML2 because I didn't want to muck around in the code too much,
for fear of introducing a subtle bug somewhere.)

Usage
=====

This template setup should build a minimal example project right out
of the box, using the standard Autotools commands.  That is, to build
the minimal example, run:

    autoconf
    ./configure
    make

The included minimal example doesn't require any extra libraries, but
as an example, if your project were to require some libraries that
happen to be installed in your `$HOME/.local` directory, you would
run:

    autoconf
    LDFLAGS=-L$HOME/.local/lib CPPFLAGS=-I$HOME/.local/include ./configure
    make

After the the build process completes, the final build targets should
be sitting in `Linux-stage`.  (I'm assuming you're running Linux, but
if not, the slightly different name of the actual staging directory
should be obvious.  Also, I've named the build, staging and test
directories based on the output of `uname` so that you can have
multiple architectures building in the same network-mounted directory,
but if you don't like that naming convention, it's easy to change.)
You can verify everything is working by running:

    ./Linux-stage/bin/hello

Note that the `hello` program successfully finds the `libfoo.so`
shared library, thanks to Libtool.

You can build the unit tests by running `make tests`, and you can run
them by running `make runtests`.  The installation process will not
install unit tests into the install prefix with all the other build
targets; unit tests are in their "own little world."

You could also do a `make install` and a `make uninstall`, if you're
feeling saucy.  If experimenting with /usr/local gives you the creeps,
you could run `configure` with a `--prefix=$HOME/tmp/local` flag to
install everything into a temp directory.

Now: the point of this template is to start you off with a lot of
boilerplate written.  That doesn't mean that you won't have to
maintain your build process; this will just start you off with some
nice features like `make uninstall`, so that you don't have to write
another `uninstall` rule every time you start a new project.  In order
to adapt this template for your own project, you will probably want to
do the following:

* Replace this `README.md` file with one that is appropriate for your
    project.  You should probably also replace (or delete) the
    `COPYING` file, and maybe the `INSTALL` file, if you've seen fit
    to modify the build/install process.

* Add in your own modules.  (You can replace the `foo` module and/or
    the `tinyxml2` module, and use them as templates.  It's unlikely
    the "Hello, world!"  functionality provided by the foo module will
    be super-useful for your project, anyway.)

* Edit `Makefile.in`:

    - Change `pkg_name := one_true_makefile` to refer to the name of
        your project.

    - Change the `modules :=` area to reflect the names of your
        modules.  For example, if you killed the `foo` module, kept
        the `tinyxml2` module, and added two more modules called bar
        and baz, you would change this section to:

        <pre><code>modules := \
            tinyxml2	bar	baz</code></pre>

    - Change the `testmodules :=` area to reflect the names of your
        unit test modules.  For example, if you used the `testfoo`
        module as a template to make a `testbar` module, you would
        change this section to:

        <pre><code>modules := \
            testbar</code></pre>

* Edit your `module.mk` files to list all of the files you want to be
    listed as dependencies, and all the files you want to be affected
    by the `make install` target.  Everything uses the bottom source
    directory as the base directory, and the One True Makefile is set
    up to mirror the organization of the staging directory.  Things in
    `etc` or `share` will just get copied around by Make, since they
    don't need to be compiled.

    For example, if you made a `baz` module with a config file at
    `baz/etc/my_project/baz/bazqux.conf`, then you want to make sure
    `baz/module.mk` has this line:

    <pre><code>baz_etcs := $(stage_dir)/etc/$(PKG_NAME)/baz/bazqux.conf</code></pre>

    On the other hand, maybe you want your `bazqux.conf` file to go in
    the bottom of `etc`, instead of in a series of subdirectories.  In
    that case, then in your `baz` module the config file would be
    located at `baz/etc/bazqux.conf`, and the line in `baz/module.mk`
    would look like this:

    <pre><code>baz_etcs := $(stage_dir)/etc/bazqux.conf</code></pre>

    In the first case, running `make install` with the default
    `/usr/local` value as your install prefix would install that
    config file to `/usr/local/etc/my_project/baz/bazqux.conf`.  In
    the second case, it would get installed to
    `/usr/local/etc/bazqux.conf`.  That is, in your `module.mk` file,
    you specify build targets in the staging directory (even if the
    "building" is just trivial copying).  The Makefile manages
    everything with implicit rules, and works such that the
    organization of your module, the organization of the staging
    directory, and the organization of the final install directory
    (e.g. `/usr/local`) will all mirror each other.

    Note that your `module.mk` files will probably also need to
    include logic regarding linking, near the bottom.  Be sure to
    include order-only rules (with a vertical bar) to tell Make to
    create relevant directories.  The `test_foo` module has an example
    of some slightly nontrivial linking logic, near the bottom of the
    file.

    Also note that `*.h` and `*.hpp` files that aren't going to be
    installed should *not* be mentioned in the `module.mk` files.  The
    dependency autogeneration feature from gcc will deal with them,
    and since they aren't going to be installed, there's no reason to
    list them manually anywhere.  (Also note that `.h` and `.hpp`
    files that are not going to be installed should go in src/
    directories, and not in include/ directories.)

* If you're keeping tinyxml2, and you've renamed your package from
    something other than `one_true_makefile` (which is
    understandable), then you'll need to edit the tops of the tinyxml2
    source file to reflect that.  For example, if your new project is
    called MyProject, then in tinyxml2.cpp and xmltest.cpp, you'll
    have to change the lines that say

    <pre><code>#include "one_true_makefile/tinyxml2/tinyxml2.h"</code></pre>

   to

    <pre><code>#include "MyProject/tinyxml2/tinyxml2.h"</code></pre>

* Rename all the directories named `one_true_makefile` to your
    project's name.

* Once your modules are set up, run `autoscan`, and replace
    `configure.ac`.  It is convenient to have your own Autoconf tests
    in a separate file (or files), so it is probably a good idea to
    put your own Autoconf tests in the `project.m4` file, and add a
    line like this to your new `configure.ac`:

    <pre><code>m4_include([project.m4])</code></pre>

    The provided `project.m4` file has a handful of tests you might
    find useful.

    One slightly non-standard aspect of the One True Makefile setup is
    that I've put `config.h` in subdirectory called `include`, instead
    of with all the build stuff in the base directory, so you will
    also want to modify the `AC_CONFIG_HEADERS` and `AC_CONFIG_SRCDIR`
    lines in a newly generated `configure.ac` to this:

    <pre><code>AC_CONFIG_SRCDIR([include/config.h.in])
    AC_CONFIG_HEADERS([include/config.h])</code></pre>

    Our default version of `configure.ac` already has these changes
    made, but if and when you run `autoscan` and replace
    `configure.ac`, you'll have to redo them.  (Minimizing the amount
    of stuff you have to redo after running `autoscan` is the purpose
    of the `project.m4` scheme.)

    If you don't like the `include/config.h` scheme, it's easy to
    change; you just have to change some lines in `Makefile.in`, near
    the configure rules, along with a line near the top of
    `project.m4`.  (In both cases, it should be obvious what to
    change.)  Also, `foo/module.mk` has a `-Iinclude` compiler flag,
    so if you don't like the `include/config.h` scheme, your modules
    should specify `-I.` instead.  (The dot after the -I is not a
    typo.  Since all paths are relative to the base directory, where
    `Makefile.in` is, the dot refers to that base directory.)

* Run `autoheader`.

Note that, while `make clean` works automagically, there is also a
`make clobber` target.  This removes final build targets and
dependency (`*.d`) files.  It also removes unit test build targets;
however, that part isn't handled automatically for you, in the sense
that the logic for removing unit test build targets has to be manually
added to the bottom of the unit test modules' `module.mk` files.
(Check out the bottom of `test_foo/module.mk` to see what I mean.)

Troubleshooting
===============

If something is screwed up, sometimes Make will silently die, rather
than giving a helpful error message.  You can tell whether Make is
silently dying by typing `make`; if it just returns, without saying
`make: Nothing to do for 'all'.` or anything else, then it is silently
dying.  Another obvious way is to see if there is a problem is to
check the return code by running:

    make || echo err

If it says "err", the return code of `make` incicated that something
went wrong, even if you don't have an error message.

Trying passing various debugging flags to `make`, such as `make -d`,
`make --debug=a`, `make --debug=b`, `make --debug=v`, `make
--debug=i`, `make --debug=j` and/or `make --debug=m` may be helpful.

Sometimes renaming files can cause problems, in that this causes the
dependency files (i.e. the `*.d` files) to be inaccurate.  A way to
fix this is to delete all the dependency files so that they will be
regenerated correctly.  One way to do this is to run:

    find . -type f -name "*.d" -exec rm -vf {} \;

You may also want to start fresh by deleting all the output of the
entire build process by running:

    rm Linux-* -rf

(If you're not on Linux, it should be obvious how to change this
line.)

Often, the problem will be in a specific spot in `Makefile.in` or one
of the `module.mk` files.  A way to identify the problem area is to
edit the `modules :=` area of `Makefile.in` and remove one module,
leaving all the other modules in the list.  If you can get it to say
`make: Nothing to do for 'all'.`, then the module you've removed is
the problem child.  Once you've narrowed the problem down to one file,
it should be easier to figure out what's wrong.  (Of course, if one of
the remaining modules depends on the removed module, Make may die with
an error message without getting to the end.  In that case, you may
have to play games with removing multiple modules at once.)

Another helpful source of information is to look in the `Linux-build`
directory (or whatever you've named it).  For example, if
`foo/module.mk` contains the problem area, and `build/foo/foo.lo`
exists, but `Linux-stage/bin` does not contain the `foo` executable,
then Make apparently died before creating the `foo` executable but
after successfully compiling `foo.lo`.  Maybe that would suggest
something to you.  (This isn't definitive-- maybe the `foo` executable
also has other dependencies, and one of those is causing the problem.)

Problems with Make can be opaque sometimes.  At one point I had a
problem with the `include/stamp-h.in` logic in `Makefile.in`, and it
seemed like Make was dying in one of the modules, in a completely
unrelated spot, since that module happened to look at
`include/config.h`.  Again: using the One True Makefile as a template
does not save you from ever having to debug Makefiles again.  It just
saves you from having to write a lot of boilerplate every time you
start a new project.

