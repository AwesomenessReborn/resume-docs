$pdf_mode = 1;
# Fallback for bare `latexmk` runs so nothing lands in the repository root.
# `make` passes -outdir/-auxdir per variant (build/work/<variant>) and then
# publishes the PDF to build/pdf; plain latexmk never publishes.
$out_dir = 'build/work';
$aux_dir = 'build/work';
$max_repeat = 5;

# Keep log lines unwrapped so scripts/build-report.pl can parse them.
$ENV{max_print_line} = 10000;

# No -halt-on-error: pdflatex keeps going after an error so the log (and the
# `make` report) lists every error, not just the first one.
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
