// § modAliasPkgBaseTopView484v (program alias of a package union)
package p;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
endpackage
program prg;
  typedef p::un_t u2_t;
  u2_t w;
  initial begin w.r = 8'h3; $display(w.q); end
endprogram
