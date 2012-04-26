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
LIBDIR=/${libdir}
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

#install: compile
install:
	mkdir -p $(DESTDIR)${BINDIR}
	mkdir -p $(DESTDIR)${OADIR}
	mkdir -p $(DESTDIR)${OALIBDIR}
	mkdir -p $(DESTDIR)${OABINDIR}
	mkdir -p $(DESTDIR)${OACONFIGDIR}
	mkdir -p $(DESTDIR)${OAVARDIR}
	mkdir -p $(DESTDIR)${OAPLUGINDIR}
	for dep in deps/*; do \
	  ./install.sh $$dep $(DESTDIR)${OALIBDIR} ; \
	done
	./install.sh . $(DESTDIR)${OALIBDIR}
	for app in ./include_apps/*; do \
	  ./install.sh $$app $(DESTDIR)${OALIBDIR} ; \
	done
## Plug-ins
	mkdir -p $(DESTDIR)${OAPLUGINDIR}
## Configurations
	sed \
	-e 's|%LOG_DIR%|${OALOGDIR}|g' \
	-e 's|%PLUGIN_DIR%|${OAPLUGINDIR}|g' \
	./config/app.config > $(DESTDIR)${OACONFIGDIR}/app.config
	sed \
	-e 's|%DB_DIR%|${OADBDIR}|g' \
	./config/vm.args > $(DESTDIR)${OACONFIGDIR}/vm.args
## Var dirs
	mkdir -p $(DESTDIR)${OADBDIR}
	mkdir -p $(DESTDIR)${OALOGDIR}
## Bin
	cp ./scripts/openacd $(DESTDIR)${OABINDIR}
	cp ./scripts/nodetool $(DESTDIR)${OABINDIR}
	cd $(DESTDIR)$(BINDIR); \
	ln -sf ..${OABINDIR}/openacd openacd; \
	ln -sf ..${OABINDIR}/nodetool nodetool

dist: deps
	./hooks.sh pre_compile
	mkdir -p tarball/OpenACD
	rsync -aC $(tarballfiles) tarball/OpenACD
	rm -rf tarball/OpenACD/deps/protobuffs/cover.spec
	cd tarball && tar -czf $(TARBALL) OpenACD

uninstall:
	rm -rf $(DESTDIR)$(OADIR)
	rm -rf $(DESTDIR)$(OACONFIGDIR)
	rm -rf $(DESTDIR)$(OAVARDIR)
	rm -rf $(DESTDIR)$(OALOGDIR)
	rm -f $(DESTDIR)${BINDIR}/openacd
	rm -f $(DESTDIR)${BINDIR}/nodetool

rpm: dist
	QA_RPATHS=0x0003 rpmbuild -tb $(TARBALL)

.PHONY: all deps compile clean run install dist rpm
