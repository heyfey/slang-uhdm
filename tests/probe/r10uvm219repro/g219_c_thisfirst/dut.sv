// r10uvm219 grid arm C — THE `this` AT THE FRONT OF THE BLOCK.
// The bare `this` is the FIRST unresolvable forwarded reference in source
// order; two hoisted class-property names follow it.  This is the arm that
// distinguishes "insert at the end of the forwarded block" from "insert where
// the anchor's span sorts inside it".
package pc0;
  class Cc0;
    int pc_a;
    int pc_b;
    extern function void f0();
    extern function void f1();
  endclass
  function void Cc0::f0();
    $display("%p", this);
  endfunction
  function void Cc0::f1();
    int lc_a; pc_a = lc_a;
    begin
      int lc_b; pc_b = lc_b;
    end
  endfunction
endpackage

module gc_thisfirst;
  import pc0::*;
  logic gc_clk;
  initial $dumpvars(0, gc_thisfirst);
endmodule
