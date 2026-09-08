// r10uvm219 grid arm G — THE CONJUNCT WITH § transitiveImportRidesTheHoist217.
// A two-hop package chain (pg1 wildcard-imports pg0) whose DEEP package holds
// the class whose method leaves the bare `this`, imported by a module with its
// own `$dumpvars` scope name.  § 217's hoist must still deliver both listings
// AND the `this` wire must still land inside the forwarded block.
package pg0;
  int g0_own;
  class Cg0;
    int g0_prop;
    extern function void doit();
  endclass
  function void Cg0::doit();
    int g0_loc;
    g0_prop = g0_loc;
    $display("%p", this);
  endfunction
endpackage

package pg1;
  import pg0::*;
  int g1_own;
endpackage

module gg_deep;
  import pg1::*;
  logic gg_clk;
  initial $dumpvars(0, gg_deep);
endmodule

// The ONE-HOP CONTROL, in the same file: `pg0` imported DIRECTLY, so
// `bindHoistedClassPropRefs` reaches its class property and the forwarded
// block is COMPLETE.  Here the patched listing must be golden's EXACTLY.
// The deep module above cannot be, on either binary, because r10uvm217's R2
// (`bindHoistedClassPropRefs` tests the DIRECT import set) leaves `g0_prop`
// unminted there -- a hole that is one element wide on BOTH binaries and is
// what shifts every later position.
module gg_near;
  import pg0::*;
  logic gn_clk;
  initial $dumpvars(0, gg_near);
endmodule
