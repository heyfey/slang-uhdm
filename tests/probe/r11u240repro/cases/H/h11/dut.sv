// § hoistPoolSourceOrder240: the constant slots (indexed part-select base, replication operand, index; a non-constant count is illegal)
package hp;
  class zb;
    int lo, w, n;
    logic [31:0] d;
    extern function logic [31:0] get();
  endclass
  function logic [31:0] zb::get();
    logic [31:0] r;
    r = d[lo+:4] | {4{d[lo]}} | (d >> w) | d[n];
    return r;
  endfunction
  class aa;
    int lo, w, n;
    logic [31:0] d;
    extern function logic [31:0] get();
  endclass
  function logic [31:0] aa::get();
    return d[lo] + w + n;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
