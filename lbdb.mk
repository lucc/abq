#!/usr/bin/make -f

# A rewimplementation of the idea of lbdb in as a make file.

CACHE = ~/.cache/lbdb

# This names all the methods used and also their priority.  The first an email
# address is found in several sources only the first one will be used.
LISTS = \
	khard \
	gpg \
	inmail \

DONTBUILD = \
	    $(GNUPGHOME)/pubring.kbx    \
	    ~/.local/share/khard/main/*.vcf \
	    $(MAILS)

SORT = sort --uniq --field-separator='	' --key=1,1

$(CACHE)/lbdb: $(patsubst %,$(CACHE)/%.sorted,$(LISTS))
	$(SORT) $^ > $@

$(CACHE)/inmail.list: ~/.config/lbdb/m_inmail.list
	cp -f $< $@

$(CACHE)/khard.list: ~/.local/share/khard/main/????????????????????????????????????.vcf
	khard email --parsable --display first_name --remove-first-line \
	| sed 's/\t[^\t]*$$/\t@/'                                       \
	> $@

ifndef GNUPGHOME
  GNUPGHOME = ~/.gnupg
endif
$(CACHE)/gpg.list: $(GNUPGHOME)/pubring.kbx
	gpg --list-keys --with-colons 2>/dev/null \
	| sed -n -e '/^\(pub\|uid\):[^re]:\([^:]*:\)\{7,7\}[^<>:]* <[^<>@: ]*@[^<>@: ]*>[^<>@:]*:/ {' \
		 -e '  s/^\([^:]*:\)\{9,9\}\([^<:]*\) <\([^>:]*\)>.*:.*$$/\3	\2	(GnuPG)/'     \
		 -e '  s/	\([^	]\{27,27\}\)[^	]*	/	\1...	/'                    \
		 -e '  p'                                                                             \
		 -e '}'                                                                               \
	> $@

# The *.list files depend on the cache directory.
$(foreach target,$(LISTS),$(eval $(CACHE)/$(target).list: $(CACHE)/.dir))
# Some entries need to be normalized.
%.normalized: %.list
	cat $< > $@
# Sort each source individually, just in case we might need it.
%.sorted: %.normalized
	$(SORT) < $< > $@
%/.dir:
	mkdir -p $*
	touch $@
$(DONTBUILD):;

clear-cache:
	$(RM) -fr $(CACHE)

cache-statistics: $(CACHE)/lbdb
	wc $(patsubst %,$(CACHE)/%.sorted,$(LISTS))
	wc $(CACHE)/lbdb

.SECONDARY:
