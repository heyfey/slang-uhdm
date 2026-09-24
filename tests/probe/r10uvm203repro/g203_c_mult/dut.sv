// r10uvm203 grid arm C — MULTIPLICITY 1: a MODULE-scope import only, with the
// same out-of-body constructor shape arm A uses at multiplicity 3.
package pc203;
  int pc_own = 3;
  class Cc203;
    extern function new();
  endclass
  function Cc203::new();
    int   c_fn_int;
    Cc203 c_fn_cls;
    begin
      string c_blk_str;
      c_blk_str = "b";
    end
    c_fn_int = 0; c_fn_cls = null;
  endfunction
endpackage

module gc203;
  import pc203::*;
  bit clk;
endmodule
