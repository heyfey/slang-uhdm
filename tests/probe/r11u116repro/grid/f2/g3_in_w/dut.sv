package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic clk;
  logic [4*32-1:0] q [4];
  logic [4*32-1:0] d [4];
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      if (1) begin : gn
        initial begin
          q[f][b*P+:P] = d[f][b*P+:P];
          v[f][P] = d[f][P];
          v[f][P-1:0] = d[f][P-1:0];
          q[f][P*b] = d[f][b+P];
        end
      end
    end
  end
endmodule
