Context

The original context is inspired by Python/Docutils ContextStack, used in the
rSt parser to track parser state. It is a type of object that holds attributes
with values, and that can create new objects which inherit the attributes. These
can overrides some or all of them, or add new attributes. Ie. essentially
stacking a new value on those of existing super context(s).

It is a good mechanism to track stacked calls and other types of layering
where subs need access to the entire state, but that should only be allowed to
change a copy for it in some particular scope. Of which there can be many
different ones. Added benefit is the possibility to inspect and evalute any part
of the current stack, wether its immedieate super-context, the root
context or anything in between.

It is a good mechanism to track stacked calls and other types of layering
where subs need access to the entire state, but that should only be allowed or
need to have local values or have structures overlayed.

That, and the ``o.key`` access vs. the python index access ``o['key']```  syntax
is a useful feature.

I find it a useful object to mount all state into, sort of like a '/' for
filesystems. Every aspect of the configuration or setup can be exposed under a
single root.

- hold static settings, loaded before starting. arguments, config names,
  file layout, dependency metadata.
  Even the argument specification or other docs.

- provide a place to index instances of application classes, list models,
  controllers, templates. The context can even take over some controller
  functionality in its prototype, and offer it to every object with access to
  the context.

This JavaScript port is based on the same idea. JS has period-access built in,
but there are other areas where some optimization was sought or some issue was
found:

- JSON import/export
- JSON path references
- standardized types, programming contracts
- path transpose

JSON
----
Context is a natural place for system, host and user configs and runcom type
data loaded during operation of an application. But some thought and care is
needed if there are custom or complex types in the tree that do not naturally
serialize, and may need help unmarshalling as well.

Path references open up a sort of hypertext for JSON, and are one of the first
things to support. Allowing user-data to contain references within or outside
of the data files makes it very powerful.

That said I think loading and exporting data is not for nodelib to prescribe
but can easily be provided on node by a per-app basis.

Contracts
---------
This is opening up the worlds of API or data or schema versioning, and migration,
and finally also something JS does not have: interfaces.

That set aside for a moment, the way many types of objects in a program would
potentially work on the same in-memory datastructure may create somewhat of a
dependency and versioning nightmare. Allowing an component X to inspect state of
some component Y introduces a dependency on the innards. Horrible. Yes. But so
convenient. For small-scale, prototype phase applications at least.

Ideally we need

- a guarantuee about the schema and version
- or an adapter or service that can provide the same, or
- some other classification to limit or verify component <-> context access

I think the best way is adopting the power of the masses, and look towards a
Symfony service-container type of external dependency injection that works
easily in node.js and github land. So go for option 2. Out-source the unresolved
issue of interface/apater/type definition.

And this also gets into component-framework land, where JS has I think some
issues to resolve there before we can see some progress in the ecosphere.
Cf. WebIDL.
Mozilla had a nice framework called XPCOM as part of its initial open-source
release. Way back when the web was still under 10 years old they had with it
a way to interface JS with native C++ compiled components and evidently.
It looks like its still there\ [#]_, this is how it looks when
Javascript code seeks to interact with native components::

	var cmgr = Components.classes["@mozilla.org/cookiemanager;1"]
											 .getService();
	cmgr = cmgr.QueryInterface(Components.interfaces.nsICookieManager);

This fixes the type of object that the script can work on exactly, by the C
types, and by given component Id, version and an interface. Very neat. You can
click through a `slideshow`_ on Web IDL to get an idea of some of the current
issues still in binding with C++.


.. _slideshow: http://mcc.id.au/2013/lca-webidl/

.. [#] https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XPCOM/Guide/Creating_components/Using_XPCOM_Components


Path transpose
--------------
A namespace is nice, unless it gets in the way::

  System.out.println(...
  /usr/share/local/...
  http://wwww...
  sudo systemctl ...

It's not bad, but not always that great either to get forced into predefined
namespaces. It can get out of hand. Have a try navigating the folders that
your OS' package manager uses for example. Less is more.

More to the point, standardization is important. Even if clumsily done.
And it should be encouraged always\ [#]_. But there's also a little flexibility
needed if working with namespaces build into our language or environment.

.. [#] https://news.ycombinator.com/item?id=3520132

Part of it is addressed perhaps by using a default or current working context.
And relative paths too.
E.g. that solves some of the issues of e.g. / vs. ~/ and many more.

Symbols.
Aliases come in many forms. An alias is essentially a virtual remount of a
single leaf, or subtree. It transposes a reference targetting one path to
another new path. A symlink, but also an import or include share a similar
effect, the localname 'name' has one real and one new virtual location::

  name.html -> ../.build/name.html

  # ~/name.rst
  .. include:: ../.build/name.rst

  # ~/name.coffee
  name = require '../.build/name'

The thing an alias cannot provide for is union mounting, merging different
namespaces into one.

For contained, non-overlapping hierarchies such as filesystems traditionally are
this makes sense. But with domain data this does not. Besides multi-user,
multi-host considerations, its wrong to assume ``/boot`` or ``/root`` mean
the same to everyone or in evey context. Besides the customer is king right.
Leaving aside the choice of OS, can't we not say something more meaningful and
informative though about our work instead of having to say, 'here is my bunch
of files'?

Conclusion
----------

