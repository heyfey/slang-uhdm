// r10uvm197 grid arm F — the SIZE is over the RAW SOURCE characters, so an
// escape and a backslash are the arms that separate "8 x characters written"
// from "8 x characters meant".
package fPkg;
  parameter string F_NL   = "a\nb";
  parameter string F_BS   = "a\\b";
  parameter string F_QUOT = "a\"b";
  parameter string F_TAB  = "a\tb";
endpackage
import fPkg::*;
module fMod;
  initial $display(F_NL);
endmodule
