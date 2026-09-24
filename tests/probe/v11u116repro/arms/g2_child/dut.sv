package p;
  parameter int unsigned P = 32;
endpackage
module sub import p::*; ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) q[f][b*P+:P] <= d[f][b*P+:P];
    end
  end
endmodule
module dut ();
  sub u1 ();
  sub u2 ();
endmodule
