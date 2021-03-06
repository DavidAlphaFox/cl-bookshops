LISP?=sbcl

all: test

build:
	$(LISP)	--non-interactive \
		--load bookshops.asd \
                --load ../replic/replic.asd \
		--eval '(ql:quickload :bookshops)' \
		--eval '(asdf:make :bookshops)'

test:
	$(LISP) --non-interactive \
		--load bookshops.asd \
		--load bookshops-test.asd \
	     	--eval '(ql:quickload :bookshops-test)' # prove tests are run when loaded.

# Install dependencies, mostly for docker (gitlab CI).
install:
	git clone https://github.com/vindarel/replic/ ~/quicklisp/local-projects/replic/
	git clone https://github.com/vindarel/cl-str/ ~/quicklisp/local-projects/cl-str/


# Workflow:
# - update
# - compile
# It seems we can not parse messages with the #! prefix, as does cl-i18n with its lisp storage.
# Needed to set the charset to UTF-8 in the pot manually.
# http://www.labri.fr/perso/fleury/posts/programming/a-quick-gettext-tutorial.html
translation-base:
	xgettext --keyword=_ --language=lisp -o locale/messages.pot src/*.lisp

translation-init-locales:
	mkdir -p locale/po/fr_FR/
	mkdir -p locale/mo/fr_FR/
	msginit --input=locale/messages.pot --locale=fr_FR -o locale/po/fr_FR/messages.po

translation-update: translation-base
	msgmerge --update locale/po/fr_FR/messages.po locale/messages.pot

translation-compile:
	msgfmt -o locale/mo/fr_FR/messages.mo locale/po/fr_FR/messages.po
