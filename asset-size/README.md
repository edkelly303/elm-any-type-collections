# Asset size tests for edkelly303/elm-any-type-collections

To compare the worst-case asset output sizes for this package with the sizes produced by `elm-core` Dict:

1. Make sure you have `uglifyjs` and `esbuild` installed

```bash
$ sudo apt install uglifyjs esbuild
```

2. Run this script to build, minify and gzip assets, then compare sizes

```bash
$ . compare-asset-size.sh
```