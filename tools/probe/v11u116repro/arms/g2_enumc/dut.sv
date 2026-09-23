package p;
  typedef enum logic [5:0] {A = 6'd3, P = 6'd32} e_t;
endpackage
module dut import p::*; ();
  logic clk;
  logic [127:0] q [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) q[f][P] <= q[f][P];
    end
  end
endmodule
