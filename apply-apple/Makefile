# Standalone build for the Apple Cloud AI Platform application.
# Compiles hari-resume-swe.tex in this folder; the PDF and all LaTeX
# artifacts (aux, log, synctex, ...) are written next to it.
# Shared preamble/commands are read from the repo root via TEXINPUTS.

LATEXMK ?= latexmk
NAME := hari-resume-swe

export TEXINPUTS := ..:
export max_print_line := 10000

.PHONY: all clean

# latexmk does its own up-to-date checking, so always hand off to it.
all:
	$(LATEXMK) -pdf -synctex=1 -interaction=nonstopmode -file-line-error $(NAME).tex

clean:
	$(LATEXMK) -C $(NAME).tex
