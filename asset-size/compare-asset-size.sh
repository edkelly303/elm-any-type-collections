#!/bin/sh

# Credit to lydell for the tips on minification from https://discourse.elm-lang.org/t/what-i-ve-learned-about-minifying-elm-code/7632

elm make --optimize --output=Any.js src/Any.elm
uglifyjs Any.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters' | esbuild --minify --target=es5 > Any.min.js

elm make --optimize --output=Core.js src/Core.elm
uglifyjs Core.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters' | esbuild --minify --target=es5 > Core.min.js

echo ">> Compiled size" 
echo "Any.js:         $(wc < Any.js -c) bytes"
echo "Core.js:        $(wc < Core.js -c) bytes"
echo -e "\n>> Minified size"
echo "Any.min.js:     $(wc < Any.min.js -c) bytes"
echo "Core.min.js:    $(wc < Core.min.js -c) bytes"
echo -e "\n>> Gzipped size"
echo "Any.min.js.gz:  $(gzip Any.min.js -c | wc -c) bytes"
echo "Core.min.js.gz: $(gzip Core.min.js -c | wc -c) bytes"

rm Any.js Any.min.js Core.js Core.min.js