// r10uvm197 grid arm C — the same typed-string import taken by a MODULE, an
// INTERFACE and a PROGRAM out of ONE file-scope import item, so the copy count
// is 2 per item (§ modUnitImportParamsTwice196) and the SIZE is the question.
package cPkg;
  parameter string C_STR = "cee";
  parameter int    C_INT = 4;
endpackage
import cPkg::*;
module cMod;   initial $display(C_STR); endmodule
interface cIf; initial $display(C_STR); endinterface
program cProg; initial $display(C_STR); endprogram
