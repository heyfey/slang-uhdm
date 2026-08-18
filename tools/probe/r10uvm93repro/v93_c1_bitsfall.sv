// v93 C1 — the $bits-fallback slice sizes (time/realtime/real/shortreal) in
// every home, in BOTH views.  This is the shape that SEGFAULTED.
package pc1;
  function automatic void pf(inout bit [63:0] v);
    { << real { v } } = v;
  endfunction
endpackage
class Cc1;
  bit [63:0] m;
  function void f(); { << time { m } } = m; endfunction
  function void g(); { << realtime { m } } = m; endfunction
  function void h(); { << shortreal { m } } = m; endfunction
endclass
interface Ic1;
  bit [63:0] v;
  initial { << real { v } } = v;
endinterface
module c1_bitsfall;
  bit [63:0] v, w;
  Ic1 ic1();
  initial begin
    { << real      { v } } = w;
    { << realtime  { v } } = w;
    { << shortreal { v } } = w;
    { << time      { v } } = w;
    { >> real      { v } } = w;
    { >> time      { v } } = w;
  end
  always_comb { << real { w } } = v;
  generate if (1) begin : gg
    bit [63:0] gv;
    always_comb { << time { gv } } = gv;
  end endgenerate
endmodule
