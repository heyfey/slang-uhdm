// r10uvm199 grid arm C — the SAME file-scope import item taken by a MODULE,
// an INTERFACE and a PROGRAM.  MiniAmiq's materialized copies live in an
// `interface_inst` DEF listing, so the interface arm is the one that speaks
// for that row.
package cPkg;
  parameter        C_UHEX = 'hf00;
  parameter int    C_INT  = 4;
endpackage
import cPkg::*;
module cMod;   initial $display(C_INT); endmodule
interface cIf; initial $display(C_INT); endinterface
program cProg; initial $display(C_INT); endprogram
