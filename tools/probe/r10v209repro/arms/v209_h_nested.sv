// v209 verifier arm H — NESTED STATEMENT BLOCKS inside the out-of-body
// constructor: a plain begin, a named begin, a for-loop body, and a `static`
// declared INSIDE a nested block.  The law reads slang's per-variable
// lifetime; golden reads the block_item_declaration's own qualifier.
package ph209;
  class ch209a;
    int n;
  endclass
  class ch209b;
    int q;
    extern function new();
  endclass
  function ch209b::new();
    ch209a lh_top;
    begin
      ch209a lh_anon;
      static ch209a lh_anon_static;
      lh_anon = null;
      lh_anon_static = null;
    end
    begin : nb209
      ch209a lh_named;
      static int lh_named_static;
      lh_named = null;
      lh_named_static = 0;
    end
    for (int ih209 = 0; ih209 < 2; ih209++) begin
      ch209a lh_loop;
      lh_loop = null;
    end
    lh_top = null;
    q = 1;
  endfunction
endpackage

import ph209::*;

module gh209;
  initial $display("h");
endmodule
