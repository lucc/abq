PREFIX = $(HOME)/.local
DESTDIR =

abq.sh.configured: abq.sh
	sed 's#^makefile=.*#makefile="$(PREFIX)/lib/abq.mk"#' $< > $@

install: abq.sh.configured abq.mk
	install -D -m755 abq.sh.configured $(DESTDIR)$(PREFIX)/bin/abq.sh
	install -D abq.mk $(DESTDIR)$(PREFIX)/lib/abq.mk

clean:
	$(RM) abq.sh.configured

.PHONY: install clean
