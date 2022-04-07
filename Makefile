# Makefile for eselect-clojure
# Copyright 2022 Yen-Chin, Lee <coldnew.tw@gmail.com>
# Distributed under the terms of the GNU General Public License v2

PROJECT = eselect-clojure
VERSION = 1.0.0

DIST_FILES = ChangeLog Makefile clojure.eselect.m4
DIST_TAR_GZ = $(PROJECT)-$(VERSION).tar.gz

MODULES_PATH = "/usr/share/eselect/modules/"
INSTALL_DIR = "$(DESTDIR)/$(MODULES_PATH)"

all: clojure.eselect

ChangeLog:
	git log > ChangeLog

clojure.eselect: clojure.eselect.m4 Makefile
	m4 -DPV='$(VERSION)' clojure.eselect.m4 > clojure.eselect

install: clojure.eselect
	test -d "$(INSTALL_DIR)" || mkdir -p "$(INSTALL_DIR)"
	cp clojure.eselect "$(INSTALL_DIR)"

uninstall:
	test -f "$(INSTALL_DIR)/clojure.eselect" && \
		rm "$(INSTALL_DIR)/clojure.eselect" || true

dist: $(DIST_FILES)
	mkdir -p $(PROJECT)-$(VERSION)
	cp --parents $(DIST_FILES) $(PROJECT)-$(VERSION)
	tar -cvzf $(DIST_TAR_GZ) $(PROJECT)-$(VERSION)
	rm -rf $(PROJECT)-$(VERSION)

clean:
	test -f $(DIST_TAR_GZ) && rm $(DIST_TAR_GZ) || true
	test -f clojure.eselect && rm clojure.eselect || true
	test -f ChangeLog && rm ChangeLog || true
