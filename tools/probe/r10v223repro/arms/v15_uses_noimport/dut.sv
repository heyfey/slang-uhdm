// v15 — an interface that USES a package name by SCOPE RESOLUTION and never
// imports it (must mint nothing), beside one that imports and USES the name
// in a continuous assign, an always block and a function.
package pv15;
  int uv15 = 1;
  logic [3:0] lv15 = 4'h3;
endpackage

interface if_v15_scoped;
  logic [3:0] own_a15;
  assign own_a15 = pv15::lv15;
endinterface

interface if_v15_uses;
  import pv15::*;
  logic [3:0] own_b15;
  assign own_b15 = lv15;
  always_comb begin
    if (uv15 > 0) begin end
  end
  function automatic int f15(); return uv15; endfunction
endinterface

module m_v15_scoped;
  logic [3:0] own_m15;
  assign own_m15 = pv15::lv15;
endmodule
