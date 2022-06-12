if (exists("tikzout")) {
  set term tikz size 3.33in,1.66in font ',8'
} else {
  set term pdfcairo font "Times,18" size 5in,2.5in
}
load "common_shared.gnuplot"
