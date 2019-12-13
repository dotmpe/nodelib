# Id: nodelib/0.0.8-dev Rules.nodelib.mk

include $(DIR)/Rules.git-versioning.shared.mk

# special rule targets
STRGT += \
   usage \
   update

DEFAULT := usage
empty :=
space := $(empty) $(empty)
usage:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGT))]'

install::
	npm install
	make test

STRGT += mocha
mocha: X :=
mocha:
	mocha --check-leaks --compilers coffee:coffeescript/register test/mocha/ $(X)

test:: check mocha

update:
	git-versioning update
	npm update

build:: TODO.list

TODO.list: Makefile bin/ lib/ src/ test/ tools/ ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@ # tasks:no-check

git-pre-commit::
	@git-versioning check

build/js/lib: src
	grunt coffee:lib
build/js/lib-dev: src bin test
	grunt coffee:dev
build/js/lib-test: test
	grunt coffee:test

PRETTYG := ./tools/sh/prettify-madge-graph.sh

doc/assets/node%-deps.dot: Rules.nodelib.mk build/js/% .madgerc $(PRETTYG)
	madge --include-npm --dot build/js/$* | \
		$(PRETTYG) build/js/$* "nodelib" > $@

doc/assets/node%.dot: Rules.nodelib.mk build/js/% .madgerc $(PRETTYG)
	madge --dot build/js/$* | $(PRETTYG) build/js/$* > $@

doc/assets/node%-deps.svg: doc/assets/node%-deps.dot Rules.nodelib.mk build/js/%
	dot -Tsvg doc/assets/node$*-deps.dot \
		-Nshape=record > $@

doc/assets/node%.svg: doc/assets/node%.dot Rules.nodelib.mk build/js/%
	dot -Tsvg doc/assets/node$*.dot \
		-Nshape=record > $@

LIB_DEP_G_DOT := \
	doc/assets/nodelib.dot \
	doc/assets/nodelib-deps.dot \
	doc/assets/nodelib-test-deps.dot \
	doc/assets/nodelib-dev-deps.dot
LIB_DEP_G_SVG := \
	doc/assets/nodelib.svg \
	doc/assets/nodelib-deps.svg \
	doc/assets/nodelib-test-deps.svg \
	doc/assets/nodelib-dev-deps.svg

dep-g-dot:: $(LIB_DEP_G_DOT)
dep-g-svg:: $(LIB_DEP_G_SVG)

dep-g:: $(LIB_DEP_G_SVG) $(LIB_DEP_G_DOT)
