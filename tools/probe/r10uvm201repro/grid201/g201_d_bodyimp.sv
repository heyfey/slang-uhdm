// r10uvm201 grid arm D — a MODULE-BODY `import p::*` (ONE materialized copy)
// instead of a file-scope one (TWO).  Separates the law from the copy COUNT.
package p201d;
  parameter D_BASE = 13;
  parameter D_REFU = D_BASE;
  parameter D_EXPR = D_BASE + 1;
endpackage
module m201d;
  import p201d::*;
endmodule
