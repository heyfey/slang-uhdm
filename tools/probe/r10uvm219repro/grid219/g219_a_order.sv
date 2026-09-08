// r10uvm219 grid arm A — THE LAW.
// A package whose out-of-body class method leaves TWO names the module-level
// late binder cannot resolve — a class PROPERTY (§ classPropRefs) and a bare
// `this` (§ thisImplicitNetBoth38) — wildcard-imported by a module that ALSO
// has an unbindable name of its OWN (the `$dumpvars(0, ma)` scope argument).
// Golden's module listing must read [forwarded ..., this, then the module's
// own]; the pristine binary appends `this` after `ma`.
package pa0;
  int a0_own;
  class Ca0;
    int a0_prop;
    extern function void doit();
    extern function void doit2();
  endclass
  function void Ca0::doit();
    int a0_loc;
    a0_prop = a0_loc;
    $display("%p", this);
  endfunction
  function void Ca0::doit2();
    int a0_loc2;
    a0_prop = a0_loc2;
  endfunction
endpackage

module ga_order;
  import pa0::*;
  logic ga_clk;
  initial $dumpvars(0, ga_order);
endmodule
