# Handoff — 2026-09-28T23:57:58.044-07:00

## Mode

Repo (git-grounded)

## Goal

Provide another agent with enough context to design a sensible structure for this version-controlled resume repository, including its current contents, hosting and development environment, suitable local LaTeX/PDF engines, and options for making the build workflow platform-agnostic.

## Current Status

The repository currently contains three standalone LaTeX resume variants and has no uncommitted changes, editor configuration, documented build command, automation, or generated PDFs tracked in Git. A local workflow was discussed but not implemented: VS Code with LaTeX Workshop plus MacTeX is the recommended macOS experience, `latexmk` is the recommended build command, and Tectonic is a smaller alternative. The repository structure and cross-platform build strategy remain open for the next agent to design.

## Repo State

- **Directory:** /Users/hareee234/Dev/projects/personal/resume-docs
- **Branch:** main
- **Git status:** `## main...origin/main` (clean)
- **Recent commits:**
  - `aea3fda Update machine learning resume content`
  - `7b6934c fix`
  - `bf9d1fc update tex`
  - `df53eb4 update`
  - `cc122ea fix`
- **Changed files:** N/A; the working tree is clean. Current repository files are `hari-resume-ml.tex`, `hari-resume-swe.tex`, and `hari-resume-ee-cmpe.tex`.
- **Tests / build / lint:** not checked

## Key Decisions

| Decision | Rationale | Alternatives Rejected |
|---|---|---|
| Keep the resumes under Git version control in this repository | The repository is intended to manage resume history and related build/configuration files | N/A |
| Prefer VS Code with the LaTeX Workshop extension for local editing and PDF preview | It provides an Overleaf-like local workflow with automatic builds, side-by-side preview, diagnostics, and SyncTeX | Running the complete self-hosted Overleaf stack is unnecessarily heavy for this small repository |
| Prefer MacTeX plus `latexmk` on the current macOS machine | MacTeX offers broad package compatibility, while `latexmk -pdf` provides a conventional and reliable repeatable build | Tectonic remains viable but was not selected as the primary local recommendation |
| Treat Tectonic as a lightweight alternative | It is self-contained and can download required packages automatically | It may not match existing Overleaf documents as predictably as a full TeX Live/MacTeX installation |
| Make build entry points platform-neutral even if local installation instructions differ | The same `latexmk` commands can work on macOS, Linux, Windows, and CI when TeX Live-compatible tooling is installed | A macOS-only workflow would reduce portability |

## Constraints and Preferences

- Current host platform is macOS.
- Current editor/platform is VS Code with an AI assistant using Copilot SDK.
- The Git repository is `AwesomenessReborn/resume-docs`, intended to be hosted/versioned on GitHub.
- The source documents are LaTeX and currently live as three standalone top-level `.tex` files.
- The inspected `hari-resume-ml.tex` uses standard pdfLaTeX-compatible packages and `glyphtounicode`; pdfLaTeX should be the compatibility baseline unless all three documents are audited before changing engines.
- A platform-agnostic repository should expose the same logical build targets everywhere, while allowing platform-specific installation instructions.
- Generated PDFs, LaTeX auxiliary files, and build directories need an explicit tracking policy; none was decided in this session.
- Do not assume the three resumes can share extracted content or templates until their similarities and differences are compared.

## Do Not Do

- Do not deploy or self-host the full Overleaf application merely to compile these resumes unless the user explicitly requests collaborative browser editing.
- Do not restructure or deduplicate the resume sources before comparing all three files and confirming the desired authoring model.
- Do not commit generated PDFs or LaTeX auxiliary files without first confirming the repository's artifact policy.
- Do not make the workflow dependent only on Homebrew or macOS; those may be documented as local conveniences, not as the universal build interface.
- Do not claim the resumes compile locally yet; no engine or build was run during this session.

## Open Questions / Risks

- Should generated PDFs be committed, published only as GitHub Actions artifacts/releases, or ignored entirely? — This determines `.gitignore`, CI, and release design.
- Should the three resume variants remain independent files or share a common preamble, commands, and reusable content fragments? — The files must be compared before recommending a structure.
- Which engine should be canonical in CI: pdfLaTeX through `latexmk`, Tectonic, or both? — pdfLaTeX compatibility is likely, but only part of one file was inspected and no compilation was performed.
- Is exact Overleaf parity required? — If so, pinning a TeX Live version in a container or CI image may be preferable to relying on each developer's installed distribution.
- Should GitHub Actions build every resume on each push and expose PDFs as workflow artifacts or releases? — Automation was discussed conceptually but not selected.
- Windows support details are not confirmed; a portable command can use TeX Live and `latexmk`, but installation and path handling need documentation.
- A root `Makefile`, cross-platform task runner, container/devcontainer, or simple scripts could provide stable entry points; the preferred abstraction is not confirmed.

## Next Action

Compare `/Users/hareee234/Dev/projects/personal/resume-docs/hari-resume-ml.tex`, `/Users/hareee234/Dev/projects/personal/resume-docs/hari-resume-swe.tex`, and `/Users/hareee234/Dev/projects/personal/resume-docs/hari-resume-ee-cmpe.tex`, then propose a repository layout and canonical cross-platform build interface without editing files until the user chooses how generated PDFs should be distributed.
