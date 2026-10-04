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
- GNU-compatible `make` and `perl` (both ship with macOS; latexmk itself is a Perl script).

## Build

```sh
make            # build all three, then print a report for each resume
make swe        # same, for one variant (also: ee-cmpe, ml)
make check      # same as `make STRICT=1`: layout warnings fail the build
make V=1        # also stream the raw latexmk/pdflatex output
make clean      # delete build/ (and nothing else)
```

Override the latexmk command with `make LATEXMK=/path/to/latexmk`.

### The build report

Every `make` builds each requested variant, never stopping at the first failure, and prints one line per resume followed by a tree of every LaTeX error and warning from its log, much like Overleaf's log panel:

```text
ee-cmpe   · unchanged  1 page    build/pdf/hari-resume-ee-cmpe.pdf
  ├─ ⚠ Font shape `OT1/cmr/bx/sc' undefined using `OT1/cmr/bx/n' instead   input line 11
  └─ ⚠ fancyhdr: \footskip is too small (0.0pt): Make it at least 4.08003pt, …
ml        ✔ built      2 pages   build/pdf/hari-resume-ml.pdf
  ├─ ⚠ page count: 2 pages (target is 1)
  └─ ⚠ fancyhdr: \footskip is too small (0.0pt): …   ×2
swe       ✘ FAILED     previous PDF kept, not updated
  ├─ ✘ Undefined control sequence.   hari-resume-swe.tex:8
  │       l.8 \textbff
  ├─ ✘ LaTeX Error: Environment itemizee undefined.   hari-resume-swe.tex:10   (may be caused by an earlier error)
  │       l.10 \begin{itemizee}
  └─ → full log: build/work/swe/hari-resume-swe.log

1 built · 1 unchanged · 1 failed · 2 with warnings
```

| Status | Meaning |
|---|---|
| `✔ built` | Sources changed; recompiled and published to `build/pdf/`. |
| `· unchanged` | No source changes (latexmk compares file contents). Warnings from the last build are still shown. |
| `· unchanged … (republished …)` | Nothing to recompile, but `build/pdf/` was missing or stale, so the last successful PDF was published again. |
| `✘ FAILED` | Compile or publish failed. The previously published PDF (if any) is left in place and is **not** the current source. |

- **Errors:** every error is listed (up to 10), with file, line, and the offending source line. Later errors are tagged *may be caused by an earlier error*; fix the first one first, then rebuild.
- **Warnings:** every LaTeX, font, package, and class warning, overfull/underfull boxes, and missing characters. Repeats are collapsed to `×N`.
- **Raw output:** each variant's full log is `build/work/<variant>/hari-resume-<variant>.log`; the captured build output is `build/work/<variant>/make-output.txt`. Use `make V=1` to see it live.
- **Exit status:** non-zero if any variant failed. Warnings exit 0 unless `STRICT=1` (see [Checking layout](#checking-layout)).
- Color is used only on an interactive terminal; set `NO_COLOR=1` to turn it off.

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

For each variant, Make runs latexmk in that variant's work directory and, only if compilation succeeds, publishes the PDF into `build/pdf/`. Publishing copies to a temp file in the work directory and renames it into place:

```sh
latexmk -pdf -outdir=build/work/swe -auxdir=build/work/swe hari-resume-swe.tex
mkdir -p build/pdf
cp build/work/swe/hari-resume-swe.pdf build/work/swe/publish.tmp \
  && mv -f build/work/swe/publish.tmp build/pdf/hari-resume-swe.pdf
```

- A failed compile **or copy** fails the build and leaves the previously published PDF in place. The rename is atomic, so `build/pdf/` never holds a partially written PDF.
- If the newly compiled PDF is identical to the published one, the published file is left alone.
- The working PDF stays in `build/work/<variant>/` so latexmk can skip unchanged rebuilds. Deleting a file from `build/pdf/` and re-running `make` republishes it without recompiling.
- Change detection is latexmk's content comparison, not file timestamps, so saving a file within the same second as the last build is still detected.
- `build/` is gitignored; never commit generated output.

### Running latexmk directly

Make is the supported build-and-publish interface. Running latexmk yourself compiles **working output only** and never touches `build/pdf/`:

```sh
latexmk -pdf -outdir=build/work/ml -auxdir=build/work/ml hari-resume-ml.tex
```

A bare `latexmk -pdf <file>.tex` with no directory options falls back to `build/work/` (set in `.latexmkrc`) so nothing is written to the repository root.

## Checking layout

Every resume should be exactly one page with no overfull boxes. These two are **layout warnings**: the report flags them and prints a `LAYOUT WARNING` banner.

- By default, layout warnings still exit 0, and the PDF is published either way.
- `make check` (the same as `make STRICT=1`) builds, prints the same report, and then exits non-zero if any resume has a layout warning. It never blocks or withholds a PDF; it only changes the exit status, for scripts, CI, and agents.
- Other warnings (fonts, packages, and so on) are shown but never affect the exit status, even with `STRICT=1`.
- Fix layout problems by editing content deliberately — not by shrinking fonts, margins, or spacing.
