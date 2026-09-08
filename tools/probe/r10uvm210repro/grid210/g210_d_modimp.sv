// r10uvm210 grid arm D — the MODULE-only importer (no importing package), so
// the importing-package column of arm C has a control.
package p210d;
  parameter D_BASE   = 11;
  parameter D_EXPR   = D_BASE + 1;
  parameter D_REF    = D_EXPR;
  parameter D_REFLIT = D_BASE;
endpackage
module m210d;
  import p210d::*;
endmodule
