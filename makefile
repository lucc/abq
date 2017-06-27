PREFIX = $(HOME)/.local
DESTDIR =

lbdb.sh.configured: lbdb.sh
	sed 's#^makefile=.*#makefile="$(PREFIX)/lib/lbdb.mk"#' $< > $@

install: lbdb.sh.configured lbdb.mk
	install -D -m755 lbdb.sh.configured $(DESTDIR)$(PREFIX)/bin/lbdb.sh
	install -D lbdb.mk $(DESTDIR)$(PREFIX)/lib/lbdb.mk

clean:
	$(RM) lbdb.sh.configured

.PHONY: install clean
