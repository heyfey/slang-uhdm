// r10uvm199 grid arm B — the SAME declared-type kinds taken through a
// MODULE-BODY `import p::*` (ONE copy each) instead of a file-scope item
// (two).  It separates "the defect is the doubling" from "the defect is the
// materialized copy" — the copy count must not change the typespec verdict.
package bPkg;
  parameter        B_UHEX = 'hdead;
  parameter        B_UDEC = 21;
  parameter int    B_INT  = 3;
  parameter string B_STR  = "bee";
endpackage
module bTop;
  import bPkg::*;
  initial $display(B_STR);
endmodule
