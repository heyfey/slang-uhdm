package p;
  typedef enum logic [5:0] {A = 6'd3, B = 6'd32} e_t;
  parameter e_t P = B;
endpackage
module dut import p::*; ();
  logic clk;
  logic [127:0] q [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) q[f][P] <= 1'b1;
    end
  end
endmodule
