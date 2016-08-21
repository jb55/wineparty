
all: elm.js

elm.js:
	elm make src/Main.elm --output elm.js

clean:
	rm -f elm.js
	rm -rf elm-stuff/build-artifacts

.PHONY: elm.js

