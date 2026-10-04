# Repository Instructions

## Structure

- Keep each resume variant in its top-level `hari-resume-*.tex` file.
- Put shared packages and page geometry in `shared/preamble.tex`.
- Put shared resume commands in `shared/commands.tex`.
- Treat `build/` as generated output; never commit its contents. Final PDFs are published to `build/pdf/`; per-variant compilation artifacts (logs, aux, SyncTeX, working PDF) live in `build/work/<variant>/`.
- Leave `tmp-resume-*` scratch directories unchanged unless a validation task explicitly requires them.

## Build And Validation

- Run `make` to build every resume.
- Run `make ee-cmpe`, `make ml`, or `make swe` to build one variant.
- Use Make to build and publish. Make compiles in `build/work/<variant>/` and copies only the PDF to `build/pdf/` after a successful compile. Direct `latexmk` runs compile working output only and never publish to `build/pdf/`.
- Run `make check` after source or shared-layout changes. It reads each variant's log from `build/work/<variant>/`. Every resume must compile successfully and remain exactly one page.
- Run `make clean` to remove only the canonical `build/` output.
- Do not automatically open or render PDFs or images. Use build logs and textual page-count checks unless the user explicitly requests visual inspection.

## Editing

- Preserve pdfLaTeX compatibility and machine-readable PDF output.
- Keep variant-specific content and packages in the owning resume file.
- Prefer a shared change only when all three variants should inherit it.
- Do not reduce margins, type size, or spacing globally without validating all variants with `make check`.