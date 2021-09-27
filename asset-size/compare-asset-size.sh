#!/bin/sh

# Credit to lydell for the tips on minification from https://discourse.elm-lang.org/t/what-i-ve-learned-about-minifying-elm-code/7632

set -e

elm make --optimize --output=AnyDict.js src/AnyDict.elm
uglifyjs AnyDict.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters' | esbuild --minify --target=es5 > AnyDict.min.js

elm make --optimize --output=CoreDict.js src/CoreDict.elm
uglifyjs CoreDict.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters' | esbuild --minify --target=es5 > CoreDict.min.js

echo ">> Compiled size" 
echo "AnyDict.js:         $(wc < AnyDict.js -c) bytes"
echo "CoreDict.js:        $(wc < CoreDict.js -c) bytes"
echo -e "\n>> Minified size"
echo "AnyDict.min.js:     $(wc < AnyDict.min.js -c) bytes"
echo "CoreDict.min.js:    $(wc < CoreDict.min.js -c) bytes"
echo -e "\n>> Gzipped size"
echo "AnyDict.min.js.gz:  $(gzip AnyDict.min.js -c | wc -c) bytes"
echo "CoreDict.min.js.gz: $(gzip CoreDict.min.js -c | wc -c) bytes"

rm AnyDict.js AnyDict.min.js CoreDict.js CoreDict.min.js