MODULES = \
	service

all clean:
	for dir in $(MODULES); do \
		(cd $$dir; ${MAKE} $@); \
	done

setup: clean all
	script/init
