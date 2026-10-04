LATEXMK ?= latexmk
PERL ?= perl
BUILD_DIR := build
PDF_DIR := $(BUILD_DIR)/pdf
WORK_DIR := $(BUILD_DIR)/work
VARIANTS := ee-cmpe ml swe

# Page count and overfull boxes are warnings, not errors: a resume over one
# page is a content decision for the author, never something to auto-fix.
# STRICT=1 makes those layout warnings fail. V=1 shows raw latexmk output.
STRICT ?= 0
V ?= 0

# Aliased so the report recipe isn't treated as a recursive $(MAKE) line
# (which would make `make -n` actually build).
REPORT_MAKE := $(MAKE)
REPORT = REPORT_MAKE='$(REPORT_MAKE)' STRICT='$(STRICT)' V='$(V)' $(PERL) scripts/build-report.pl

.PHONY: all $(VARIANTS) check clean

# Remove a partially written target if its recipe fails after touching it.
.DELETE_ON_ERROR:

# Build every variant (never stopping at the first failure) and print a
# per-resume report of build status, page count, errors, and warnings.
all:
	@$(REPORT) $(VARIANTS)

$(VARIANTS):
	@$(REPORT) $@

check:
	@$(MAKE) --no-print-directory all STRICT=1

# Compile in the variant's own work directory, then publish only the PDF.
# Make stops at the first failing command, so a failed compile never replaces
# the last published PDF. Publishing copies to a temp file beside the working
# PDF and renames it into place, so build/pdf never holds a partial file; an
# identical PDF is left in place and only touched.
# The working PDF stays put for latexmk's incremental dependency tracking.
# The report runs this rule with -B on every build: latexmk's content check
# decides what changed, because Make 3.81 timestamps only have 1 s resolution.
$(PDF_DIR)/hari-resume-%.pdf: hari-resume-%.tex shared/preamble.tex shared/commands.tex .latexmkrc
	$(LATEXMK) -pdf -outdir=$(WORK_DIR)/$* -auxdir=$(WORK_DIR)/$* $<
	mkdir -p $(@D)
	if cmp -s $(WORK_DIR)/$*/hari-resume-$*.pdf $@; then touch $@; else \
		cp $(WORK_DIR)/$*/hari-resume-$*.pdf $(WORK_DIR)/$*/publish.tmp && \
		mv -f $(WORK_DIR)/$*/publish.tmp $@; \
	fi

clean:
	rm -rf $(BUILD_DIR)
