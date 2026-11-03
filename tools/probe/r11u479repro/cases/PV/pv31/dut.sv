// § pkgVirtIfaceTd479 (control: a scalar typedef imported into a program; the program listing face predates the pass)
package t;
  typedef int i_t;
endpackage
program prg; import t::*; i_t h; endprogram
module top; endmodule
