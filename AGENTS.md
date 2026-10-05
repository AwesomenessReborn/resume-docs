# Repository Instructions

## Structure

- Keep each resume variant in its own `tex/hari-resume-*.tex` file.
- Put shared packages and page geometry in `shared/preamble.tex`.
- Put shared resume commands in `shared/commands.tex`.
- The final Overleaf sync (2026-10-04) and older resumes are archived in Google Drive `My Drive/resume-docs/`; do not re-add Overleaf exports to the repository.
- Treat `build/` as generated output; never commit its contents. Final PDFs are published to `build/pdf/`; per-variant compilation artifacts (logs, aux, SyncTeX, working PDF) live in `build/work/<variant>/`.

## Build And Validation

- Run `make` to build every resume. It prints a per-resume report: status (`built`, `unchanged`, or `FAILED`), page count, and a tree of every LaTeX error and warning from the log. A non-zero exit means at least one resume failed to compile or publish.
- Run `make ee-cmpe`, `make ml`, or `make swe` to build and report one variant.
- Use Make to build and publish. Make compiles in `build/work/<variant>/` and publishes only the PDF to `build/pdf/` after a successful compile. Direct `latexmk` runs compile working output only and never publish to `build/pdf/`.
- Run `make check` (the same as `make STRICT=1`) after source or shared-layout changes. Every resume must compile successfully and remain exactly one page; `make check` exits non-zero on page-count or overfull-box warnings. Other warnings are informational.
- When a build fails, fix the first listed error first; later errors may be caused by it. For raw output, read `build/work/<variant>/hari-resume-<variant>.log` or run `make V=1`.
- Report layout warnings (page count, overfull boxes) to the user; never auto-fix them by shrinking fonts, margins, or spacing, or by cutting content.
- Run `make clean` to remove only the canonical `build/` output.
- Do not automatically open or render PDFs or images. Use build logs and textual page-count checks unless the user explicitly requests visual inspection.

## Editing

- Preserve pdfLaTeX compatibility and machine-readable PDF output.
- Keep variant-specific content and packages in the owning resume file.
- Prefer a shared change only when all three variants should inherit it.
- Do not reduce margins, type size, or spacing globally without validating all variants with `make check`.