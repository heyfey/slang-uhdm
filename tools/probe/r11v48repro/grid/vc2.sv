// vc2 — vc1's shape with the package function NEVER constant-evaluated.
package vc2p;
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
module vc2 (input logic c, output logic o);
  assign o = c;
endmodule
