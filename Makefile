all: bin/dver bin/dreg bin/har

TAG=core-dreg:local

docker-image:
	docker build -t $(TAG) .

test: docker-image
	./test.sh $(TAG)

versions: bin/list_tags
	$< > VERSIONS.txt

misc/.patched:
	cd misc && patch dreg.d < ../dreg.patch
	cd misc && patch dver.d < ../dver.patch
	touch $@

bin/dver: misc/dver.d misc/.patched
	rdmd --build-only -of$@ $<

bin/dreg: misc/dreg.d misc/.patched
	rdmd --build-only -of$@ $<

bin/list_tags: list_tags.d
	rdmd --build-only -of$@ $<

bin/har: har/harmain.d
	rdmd --build-only -of=$@ -Ihar/src $(EXTRA_DFLAGS) $<

clean:
	rm -rf bin
