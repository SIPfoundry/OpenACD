SHELL := /bin/bash
TARBALL = $(abspath $(DESTDIR)OpenACD.tar.gz)

tarballfiles = attic \
       contrib \
       deps \
       doc \
       include_apps \
       misc \
       priv \
       include \
       proto_src \
       rel \
       src \
       tests \
       LICENSE \
       Makefile \
       README.markdown \
       buildcerts.sh \
       devboot \
       gen-cpx.config.sample \
       hooks.sh \
       openacd.spec \
       rebar \
       rebar.config \
       success_message \
       install.sh \
       config \
       scripts

MACHINE := $(shell uname -m)

ifeq ($(MACHINE), x86_64)
libdir = lib64
endif
ifeq ($(MACHINE), i686)
libdir = lib
endif

BINDIR=/bin
ETCDIR=/etc
LIBDIR=/$(libdir)
VARDIR=/var

OADIR=$(LIBDIR)/openacd
OALIBDIR=$(OADIR)/lib
OABINDIR=$(OADIR)/bin
OACONFIGDIR=$(ETCDIR)/openacd
OAVARDIR=$(VARDIR)/lib/openacd
OALOGDIR=$(VARDIR)/log/openacd
OADBDIR=$(OAVARDIR)/db
OAPLUGINDIR=$(OADIR)/plugin.d

all: deps compile

deps:
	./rebar get-deps update-deps

compile:
	./rebar compile generate force=1

clean:
	./rebar clean
	rm -f $(TARBALL)
	rm -rf tarball
	rm -rf OpenACD

run: compile
	./rel/openacd/bin/openacd console

install: compile
	mkdir -p $(PREFIX)$(BINDIR)
	mkdir -p $(PREFIX)$(OADIR)
	mkdir -p $(PREFIX)$(OALIBDIR)
	mkdir -p $(PREFIX)$(OABINDIR)
	mkdir -p $(PREFIX)$(OACONFIGDIR)
	mkdir -p $(PREFIX)$(OAVARDIR)
	mkdir -p $(PREFIX)$(OAPLUGINDIR)
	for dep in deps/*; do \
	  ./install.sh $$dep $(PREFIX)$(OALIBDIR) ; \
	done
	./install.sh ../OpenACD $(PREFIX)$(OALIBDIR)
	for app in ./include_apps/*; do \
	  ./install.sh $$app $(PREFIX)$(OALIBDIR) ; \
	done
## Plug-ins
	mkdir -p $(PREFIX)$(OAPLUGINDIR)
## Configurations
	sed \
	-e 's|%LOG_DIR%|$(OALOGDIR)|g' \
	-e 's|%PLUGIN_DIR%|$(OAPLUGINDIR)|g' \
	./config/app.config > $(PREFIX)$(OACONFIGDIR)/app.config
	sed \
	-e 's|%DB_DIR%|$(OADBDIR)|g' \
	./config/vm.args > $(PREFIX)$(OACONFIGDIR)/vm.args
## Var dirs
	mkdir -p $(PREFIX)$(OADBDIR)
	mkdir -p $(PREFIX)$(OALOGDIR)
## Bin
	cp ./scripts/openacd $(PREFIX)$(OABINDIR)
	cp ./scripts/nodetool $(PREFIX)$(OABINDIR)
	cd $(PREFIX)$(BINDIR); \
	ln -sf ..$(OABINDIR)/openacd openacd; \
	ln -sf ..$(OABINDIR)/nodetool nodetool

dist: deps
	./hooks.sh pre_compile
	mkdir -p tarball/OpenACD
	rsync -aC $(tarballfiles) tarball/OpenACD
	rm -rf tarball/OpenACD/deps/protobuffs/cover.spec
	cd tarball && tar -czf $(TARBALL) OpenACD

rpm: dist
	QA_RPATHS=0x0003 rpmbuild -tb $(TARBALL)

.PHONY: all deps compile clean run install dist rpm
