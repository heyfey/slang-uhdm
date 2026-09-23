package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      function automatic logic [63:0] fn(input logic [63:0] x); logic [63:0] r; r = x; r[P] = 1'b0; return r; endfunction
      always_comb v[f] = fn(v[f]);
    end
  end
endmodule
