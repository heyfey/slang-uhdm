package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  logic [63:0] v [4];
  logic [7:0] cnt [4];
  typedef struct packed { logic [31:0] x; } s_t;
  s_t s [64];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
        final begin
          v[f][P] = d[f][0];
        end
    end
  end
endmodule
