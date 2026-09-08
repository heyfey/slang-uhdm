// r10uvm209 grid arm D — the import written INSIDE the module instead of at
// file scope.  The law is about WHAT a materialised copy carries, not about
// where the import is written, so this arm must move EXACTLY the way arm A's
// does — it is the second positive control, and its absence from the moved
// list would mean the gate is keyed on the wrong thing.
package pd209;
  class cg209;
    int n;
  endclass
  class ch209;
    int q;
    extern function new();
  endclass
  function ch209::new();
    cg209  ld_cls;
    string ld_str;
    ld_cls = null;
    q = 3;
  endfunction
  cg209 pd_cls;
  int   pd_int = 7;
endpackage

module gd209;
  import pd209::*;
  initial $display("%0d", pd_int);
endmodule
