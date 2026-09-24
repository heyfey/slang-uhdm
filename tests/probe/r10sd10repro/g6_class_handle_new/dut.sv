// g6 — THE TARGET'S OWN SHAPE: a package-scope CLASS-HANDLE variable with a
// `new()` initialiser, plus a second handle initialised with a BARE REFERENCE to
// the first — literally uvm_pkg's `uvm_default_table_printer` /
// `uvm_default_printer` pair, wildcard-imported into a class-declaring package.
package p6;
  class k6;
    int x6;
  endclass
  k6 tbl6 = new();
  k6 dfl6 = tbl6;
endpackage
package q6;
  import p6::*;
  class c6;
    int own6;
  endclass
endpackage
module m6;
  q6::c6 h6;
endmodule
