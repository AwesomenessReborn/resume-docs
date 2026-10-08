# Standalone build for the Apple Cloud AI Platform application.
# Sources live in tex/, published PDFs in pdf/, and artifacts in build/work/.

LATEXMK ?= latexmk
PERL ?= perl
VARIANTS := swe
PDF_DIR := pdf
WORK_DIR := build/work
STRICT ?= 0
V ?= 0

export TEXINPUTS := $(abspath ..):

REPORT_MAKE := $(MAKE)
REPORT = REPORT_MAKE='$(REPORT_MAKE)' REPORT_PDF_DIR='$(PDF_DIR)' REPORT_WORK_DIR='$(WORK_DIR)' STRICT='$(STRICT)' V='$(V)' $(PERL) ../scripts/build-report.pl

.PHONY: all $(VARIANTS) check clean
.DELETE_ON_ERROR:

# Always hand off to latexmk for content-based change detection.
all:
	@$(REPORT) $(VARIANTS)

$(VARIANTS):
	@$(REPORT) $@

check:
	@$(MAKE) --no-print-directory all STRICT=1

$(PDF_DIR)/hari-resume-%.pdf: tex/hari-resume-%.tex ../shared/preamble.tex ../shared/commands.tex ../.latexmkrc
	$(LATEXMK) -r ../.latexmkrc -pdf -outdir=$(WORK_DIR)/$* -auxdir=$(WORK_DIR)/$* $<
	mkdir -p $(@D)
	if cmp -s $(WORK_DIR)/$*/hari-resume-$*.pdf $@; then touch $@; else \
		cp $(WORK_DIR)/$*/hari-resume-$*.pdf $(WORK_DIR)/$*/publish.tmp && \
		mv -f $(WORK_DIR)/$*/publish.tmp $@; \
	fi

clean:
	rm -rf build
