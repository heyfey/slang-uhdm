package p;
  parameter int unsigned P = 32;
endpackage
module dut ();
  logic clk;
  logic [4*32-1:0] q [4];
  logic [4*32-1:0] d [4];
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      if (1) begin : gn
        assign q[f][b*p::P+:p::P] = d[f][b*p::P+:p::P];
      end
    end
  end
endmodule
