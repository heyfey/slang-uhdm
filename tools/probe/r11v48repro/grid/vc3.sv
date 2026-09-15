// vc3 — vc1's shape inside a MODULE function, constant-evaluated at a bound.
module vc3 (output logic [2:0] b);
  localparam int unsigned NF = 3;
  function automatic int unsigned fw(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(logic [0:2] cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NF; i++)
      if (cfg[i])
        if (fw(i) > res) res = fw(i);
    return res;
  endfunction
  localparam int unsigned W = maxw(3'b101);
  logic [W-1:0] x;
  assign b = {1'b0, x[1:0]};
endmodule
