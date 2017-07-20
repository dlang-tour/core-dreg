all: bin/dver bin/dreg

misc/.patched:
	cd misc && patch dreg.d < ../dreg.patch
	cd misc && patch dver.d < ../dver.patch
	touch $@

bin/dver: misc/dver.d misc/.patched
	rdmd --build-only -of$@ $<

bin/dreg: misc/dreg.d misc/.patched
	rdmd --build-only -of$@ $<

clean:
	rm -rf bin
