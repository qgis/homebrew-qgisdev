# Homebrew-qgisdev

Formulae for macOS Homebrew package manager to aid in building the development branch of QGIS.

## How do I install these formulae?
`brew install qgis/qgisdev/<formula>`

Or `brew tap qgis/qgisdev` and then `brew install <formula>`.

Or install via URL (which will not receive updates):

```
brew install https://raw.githubusercontent.com/qgis/homebrew-qgisdev/master/Formula/<formula>.rb
```

There may be formulae in this tap that conflict (meant to override) with formulae of the same name available in other or core `Homebrew/Homebrew-*` taps. You can *prioritize* the formulae in this tap over all others with:
```
brew tap-pin qgis/qgisdev
```

## Homebrew documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://github.com/Homebrew/brew/tree/master/docs#readme).

## Formulae naming convention

Formulae have specific suffix naming:

* `*-dev` formulae are meant for developers/testers doing local builds
* `*-travis` formulae are meant for QGIS project automated Travis CI testing
* `no suffix` dependency formulae, for QGIS dev builds, not found in other taps

## Developing QGIS using Homebrew dependencies

See: tutorial in [development/README.md](development/README.md)
