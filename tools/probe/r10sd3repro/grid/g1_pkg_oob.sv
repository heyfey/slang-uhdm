// g1 — package class with an OUT-OF-BODY method: the exact UVM shape
// (`function bit uvm_reg::has_reset(...)`).  Golden stamps every typespec the
// method mints (return type, formals, body locals) with the HOME PACKAGE.
package p1;
  class c1;
    extern function bit f1(string kind);
  endclass
  function bit c1::f1(string kind);
    string loc;
    loc = kind;
    f1 = (loc == "HARD");
  endfunction
endpackage
module top1;
  import p1::*;
  c1 h;
  initial h = new();
endmodule
