$pdf_mode = 1;
$out_dir = 'build';
$aux_dir = 'build';
$max_repeat = 5;

$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error %O %S';