Address Book Query
==================

Address Book Query is a small program that caches email addresses from several
sources and searches them in order to provide address completion for email
clients like [mutt] or [alot]. The idea is based on [lbdb] but it is here
implemented as a makefile.  Currently the following providers are supported:
* [khard]
* [gpg]
* [lbdb's inmail plugin][inmail]
* [notmuch address][notmuch address]

[alot]: https://github.com/pazz/alot
[gpg]: https://gnupg.org/
[inmail]: http://www.spinnaker.de/lbdb/lbdb-fetchaddr.html
[khard]: https://github.com/scheibler/khard
[lbdb]: https://github.com/RolandRosenfeld/lbdb
[mutt]: http://www.mutt.org/
[notmuch address]: https://notmuchmail.org/manpages/notmuch-address-1/
