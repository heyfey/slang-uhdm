// vc1 — cfg_func_width_loop's EXACT shape: a loop local as the actual of a call
// inside an IF CONDITION, package function CONSTANT-EVALUATED at a port bound.
package vc1p;
  localparam int unsigned NF = 3;
  function automatic int unsigned fw(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(logic [0:NF-1] cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NF; i++)
      if (cfg[i])
        if (fw(i) > res) res = fw(i);
    return res;
  endfunction
endpackage
module vc1sub #(parameter logic [0:2] M = '0) (output logic [vc1p::maxw(M)-1:0] b);
  assign b = '0;
endmodule
module vc1 (output logic [2:0] b);
  vc1sub #(.M(3'b101)) u (.b(b));
endmodule
