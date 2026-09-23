package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_comb begin
        for (int i = 0; i < 2; i += P) v[f][i] = d[f][i];
      end
    end
  end
endmodule
