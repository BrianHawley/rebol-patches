REBOL Patches
=============

For those of us who are caught by REBOL bugs, but need for them to be fixed
right away, we can patch it. We can even add new features to existing code.

Installation
------------

If you are running a prebuilt REBOL, perhaps one of RT's builds, then the
best way to get the patches installed is from rebol.r. Put the patches files
in the same directory as your REBOL interpreter, and put this code in rebol.r:

    import %patches.r3

Or if you have R3 and R2 in the same directory, using the same rebol.r, use
code like this:

    if system/version > 2.100.0 [import %patches.r3]

If you use **do** instead of **import** it will still work, but it will
print out the module title with **boot-print** like **do** does with all
the scripts it runs. You might not want that.

If you are building your own app with the host kit you can include the patches
file in your project. I haven't tested this yet though.

How it Works
------------

Code is data, yay!

For R3, patching can be a bit tricky. Being able to patch a function is a
pretty big security risk, and it can be just as bad to be able to get access
to bound words in a function. Because of this, R3's reflectors are fairly
locked down, giving you a copy of the spec and body of a function rather than
the original, and an unbound copy at that. So we don't patch, we recreate.

- The patches use the reflection functions of REBOL to get a copy of the spec
and body of a function. The bindings of the original code are not applied.

- They make a few changes to them, add or change some code.

- They rebind the code to the contexts that they were originally bound to.

- They create new functions based on the changed code.

- They assign the new functions to the words that the old functions were
assigned to. For functions in the **lib** context, we also replace any exports
of the words in the user context and all named modules we can access. If
you assign the function to some other word yourself, it won't replace that
version, nor will it overwrite other values than the one that used to be in
the **lib** context.

For R2, functions are pretty easy to patch if you can get access to them.
However, you have to use the old, insecure reflectors to get at the code. The
advantage (if you can call it that) is that you can trace to functions that
you shouldn't be able to access, then change the *original*, regardless of
how many times it's referenced. This makes it hard to write sandboxes in R2.

If you want your patches to work well, it is better to install them as soon
as you can. This gives you a predictable baseline to patch from. The more
code that runs before your patches, the more you have to patch.

What Doesn't Work
-----------------

We can't change code after it runs, only before it runs again. For instance,
you can't change R3's startup code in patches loaded from rebol.r, since that
code is already running when rebol.r is loaded. Make a host kit build if you
need to change things earlier.

We can't change natives. We can replace natives with new functions, but they
will no longer be of the **native!**, **action!** or **op!** types. Whether
this is a problem for you depends on the circumstances.
 
In R2, don't change code in a function while it's running or you might crash
REBOL. In particular it seems to crash when changes cause the code block to be
reallocated internally, but there might be other ways to do it. Best to not.

In R3 you can't change **function!** or **closure!** functions, you can
only replace them with new functions, and then only when that is allowed.

If you can't get access to a context, you can't bind new code to that context.
In R3 it is very difficult to get access to a context that isn't made public.
The best you can hope for is that someone might not realize that they made
something public, or be OK with that. You can also explicitly block access to
a context in R3, and (barring security bugs) you can't get around that. If
someone competent doesn't want you patching their function, you can't.

For instance, **secure** is a mezzanine in R3, but you can't replace it
with something less secure because you can't access a protected context used
inside the function. You can replace **secure**, but it doesn't help.

If you want to patch something that will be locked down, better do so before
the locking down occurs, the sooner the better.

Project Policies
----------------

It is better to document what you're patching, preferably with a CureCode or
RAMBO reference. I'll reject attempts to "fix" non-bugs or wishes that are
unlikely to be accepted into REBOL itself.

I'm trying to make the patch tests feature-based rather than version-based, to
make the patches more compatibile with host kit builds. Lots of tweaking is
expected here as new versions come out.

No exports from the patches files. Add-on functions are best put elsewhere.
Be conscious of the effects you are having on the environment.

For anything beyond that, make your own project ;-)

License
-------

Copyright (c) 2012 Brian Hawley

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
