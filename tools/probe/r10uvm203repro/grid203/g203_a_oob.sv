// r10uvm203 grid arm A — WHICH BODIES HOIST, and the module copy of each.
// A file-level `import` (multiplicity 2) plus a module-level one (+1 = 3).
package pa203;
  int pa_own0 = 1;                       // a package's own declaration
  class Ca203;
    int cprop;                           // a class PROPERTY: never hoisted
    extern function new(int n);
    extern function void notnew(int n);
    function void inbody203();
      Ca203 ib_local;                    // an IN-BODY method local: never hoisted
      int   ib_int;
      ib_local = null; ib_int = n_none();
    endfunction
    function int n_none(); return 0; endfunction
  endclass
  string pa_own1 = "mid";
  // OUT-OF-BODY CONSTRUCTOR: its locals ride into the package listing.
  function Ca203::new(int n);
    int      oob_fn_int;                 // function-body level
    string   oob_fn_str;
    Ca203    oob_fn_cls;                 // a class handle of the SAME package
    begin
      int    oob_blk_int;                // a nested `begin` level
      Ca203  oob_blk_cls;
      oob_blk_int = n; oob_blk_cls = null;
    end
    oob_fn_int = n; oob_fn_str = "x"; oob_fn_cls = null; cprop = n;
  endfunction
  // OUT-OF-BODY NON-CONSTRUCTOR: hoists NOTHING (the distinguisher).
  function void Ca203::notnew(int n);
    int    nn_fn_int;
    Ca203  nn_fn_cls;
    nn_fn_int = n; nn_fn_cls = null;
  endfunction
  int pa_own2 = 2;
endpackage

import pa203::*;                         // FILE-LEVEL: multiplicity 2

module ga203;
  import pa203::*;                       // MODULE-LEVEL: +1  => 3 copies
  bit clk;
endmodule
