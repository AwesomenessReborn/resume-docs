LATEXMK ?= latexmk
BUILD_DIR := build
PDF_DIR := $(BUILD_DIR)/pdf
WORK_DIR := $(BUILD_DIR)/work
SOURCES := hari-resume-ee-cmpe.tex hari-resume-ml.tex hari-resume-swe.tex
PDFS := $(SOURCES:%.tex=$(PDF_DIR)/%.pdf)

.PHONY: all ee-cmpe ml swe check clean

# Remove a partially written target if its recipe fails after touching it.
.DELETE_ON_ERROR:

all: $(PDFS)

ee-cmpe: $(PDF_DIR)/hari-resume-ee-cmpe.pdf

ml: $(PDF_DIR)/hari-resume-ml.pdf

swe: $(PDF_DIR)/hari-resume-swe.pdf

# Compile in the variant's own work directory, then publish only the PDF.
# Make stops at the first failing command, so a failed compile never replaces
# the last published PDF. The working PDF stays put for latexmk's incremental
# dependency tracking.
$(PDF_DIR)/hari-resume-%.pdf: hari-resume-%.tex shared/preamble.tex shared/commands.tex .latexmkrc
	$(LATEXMK) -pdf -outdir=$(WORK_DIR)/$* -auxdir=$(WORK_DIR)/$* $<
	mkdir -p $(@D)
	cp $(WORK_DIR)/$*/hari-resume-$*.pdf $@

# Page count is a warning, not an error: a resume over one page is a content
# decision for the author, never something to auto-fix. STRICT=1 makes it fail.
STRICT ?= 0

check: all
	@failed=0; warned=0; \
	for source in $(SOURCES); do \
		name=$${source%.tex}; \
		log="$(WORK_DIR)/$${name#hari-resume-}/$$name.log"; \
		pages=$$(tr -d '\n' < "$$log" | grep -Eo '\([0-9]+ pages?,' | tail -n 1 | grep -Eo '[0-9]+'); \
		overfull=$$(grep -c '^Overfull \\hbox' "$$log"); \
		if [ -z "$$pages" ]; then \
			printf 'ERROR  %s: could not read page count from %s\n' "$$name" "$$log" >&2; \
			failed=1; \
		elif [ "$$pages" = "1" ]; then \
			printf 'ok     %s: 1 page\n' "$$name"; \
		else \
			printf 'WARN   %s: %s pages (target is 1)\n' "$$name" "$$pages" >&2; \
			warned=1; \
		fi; \
		if [ "$$overfull" -gt 0 ]; then \
			printf 'WARN   %s: %s overfull box(es) - text may run past the margin (see %s)\n' "$$name" "$$overfull" "$$log" >&2; \
			warned=1; \
		fi; \
	done; \
	if [ $$warned -eq 1 ]; then \
		printf '\n' >&2; \
		printf '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n' >&2; \
		printf '!!  LAYOUT WARNING: see WARN lines above.                             !!\n' >&2; \
		printf '!!  Do NOT auto-fix by shrinking font size, margins, or spacing, or   !!\n' >&2; \
		printf '!!  by cutting content. Report it to the author and let them decide.  !!\n' >&2; \
		printf '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n' >&2; \
		if [ "$(STRICT)" = "1" ]; then failed=1; fi; \
	fi; \
	exit $$failed

clean:
	rm -rf $(BUILD_DIR)