#!/usr/bin/make -f

# A reimplementation of the idea of lbdb in a make file.

CACHE = ~/.cache/abq

# This names all the methods used and also their priority.  If an email
# address is found in several sources only the first one will be used.
LISTS = \
	khard  \
	gpg    \
	inmail \

DONTBUILD = \
	    $(GNUPGHOME)/pubring.kbx        \
	    ~/.local/share/khard/main/*.vcf \
	    $(MAILS)                        \

SORT = sort --uniq --field-separator='	' --key=1,1

$(CACHE)/abq: $(patsubst %,$(CACHE)/%.sorted,$(LISTS))
	$(SORT) $^ > $@

$(CACHE)/inmail.list: ~/.lbdb/m_inmail.list | $(CACHE)
	cp -f $< $@

$(CACHE)/khard.list: ~/.local/share/khard/main/????????????????????????????????????.vcf | $(CACHE)
	khard email --parsable --display first_name --remove-first-line \
	| sed 's/\t[^\t]*$$/\t@/'                                       \
	> $@

ifndef GNUPGHOME
  GNUPGHOME = ~/.gnupg
endif
$(CACHE)/gpg.list: $(GNUPGHOME)/pubring.kbx | $(CACHE)
	gpg --list-keys --with-colons 2>/dev/null \
	| sed -n -e '/^\(pub\|uid\):[^re]:\([^:]*:\)\{7,7\}[^<>:]* <[^<>@: ]*@[^<>@: ]*>[^<>@:]*:/ {' \
		 -e '  s/^\([^:]*:\)\{9,9\}\([^<:]*\) <\([^>:]*\)>.*:.*$$/\3	\2	(GnuPG)/'     \
		 -e '  s/	\([^	]\{27,27\}\)[^	]*	/	\1...	/'                    \
		 -e '  p'                                                                             \
		 -e '}'                                                                               \
	> $@

# Some entries need to be normalized.  TODO to be implemented!
%.normalized: %.list
	cat $< > $@
# Sort each source individually, just in case we might need it.
%.sorted: %.normalized
	$(SORT) < $< > $@
$(CACHE):
	mkdir -p $@
$(DONTBUILD):;

clear-cache:
	$(RM) -fr $(CACHE)

cache-statistics: $(CACHE)/abq
	wc $(patsubst %,$(CACHE)/%.sorted,$(LISTS))
	wc $(CACHE)/abq

.SECONDARY:
