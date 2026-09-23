package p;
  parameter int unsigned P = 32;
endpackage
module dut ();
  logic clk;
  logic [4*32-1:0] q [4];
  logic [4*32-1:0] d [4];
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    localparam int b = 1;
    if (1) begin : gn
      always_comb begin
        q[f][b*p::P+:p::P] = d[f][b*p::P+:p::P];
        v[f][p::P] = d[f][p::P];
        v[f][p::P-1:0] = d[f][p::P-1:0];
        q[f][p::P*b] = d[f][b+p::P];
      end
    end
  end
endmodule
