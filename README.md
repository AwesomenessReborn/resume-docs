# resume-docs

LaTeX sources for three resume variants that share one preamble and command set.

| Variant | Source | Make target |
|---|---|---|
| EE / CmpE | `hari-resume-ee-cmpe.tex` | `make ee-cmpe` |
| ML | `hari-resume-ml.tex` | `make ml` |
| SWE | `hari-resume-swe.tex` | `make swe` |

Shared packages and page geometry live in `shared/preamble.tex`; shared resume commands live in `shared/commands.tex`.

## Requirements

- A TeX Live–compatible distribution with `pdflatex` and `latexmk` (MacTeX on macOS).
- GNU-compatible `make`.

## Build

```sh
make            # build and publish all three PDFs
make swe        # build and publish one variant (also: ee-cmpe, ml)
make check      # build all, then report page counts and overfull boxes
make clean      # delete build/ (and nothing else)
```

Override the latexmk command with `make LATEXMK=/path/to/latexmk`.

## Output layout

```text
build/
  pdf/                      final PDFs only
    hari-resume-ee-cmpe.pdf
    hari-resume-ml.pdf
    hari-resume-swe.pdf
  work/                     compilation artifacts, one directory per variant
    ee-cmpe/                .aux .fdb_latexmk .fls .log .out .synctex.gz + working PDF
    ml/
    swe/
```

For each variant, Make runs latexmk in that variant's work directory and, only if compilation succeeds, copies the PDF into `build/pdf/`:

```sh
latexmk -pdf -outdir=build/work/swe -auxdir=build/work/swe hari-resume-swe.tex \
  && mkdir -p build/pdf \
  && cp build/work/swe/hari-resume-swe.pdf build/pdf/
```

- A failed compile or copy fails the Make target and leaves the previously published PDF in place.
- The working PDF stays in `build/work/<variant>/` so latexmk can skip unchanged rebuilds. Deleting a file from `build/pdf/` and re-running `make` republishes it without recompiling.
- `build/` is gitignored; never commit generated output.

### Running latexmk directly

Make is the supported build-and-publish interface. Running latexmk yourself compiles **working output only** and never touches `build/pdf/`:

```sh
latexmk -pdf -outdir=build/work/ml -auxdir=build/work/ml hari-resume-ml.tex
```

A bare `latexmk -pdf <file>.tex` with no directory options falls back to `build/work/` (set in `.latexmkrc`) so nothing is written to the repository root.

## Checking layout

`make check` reads each variant's log from `build/work/<variant>/` and prints `ok`, `WARN`, or `ERROR` per resume. Every resume should be exactly one page with no overfull boxes.

- Page-count and overfull-box problems are warnings by default (exit 0).
- `make check STRICT=1` turns those warnings into a failing exit status.
- Fix layout problems by editing content deliberately — not by shrinking fonts, margins, or spacing.
