$pdf_mode = 1;
# Fallback for bare `latexmk` runs so nothing lands in the repository root.
# `make` passes -outdir/-auxdir per variant (build/work/<variant>) and then
# publishes the PDF to build/pdf; plain latexmk never publishes.
$out_dir = 'build/work';
$aux_dir = 'build/work';
$max_repeat = 5;

$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error %O %S';
