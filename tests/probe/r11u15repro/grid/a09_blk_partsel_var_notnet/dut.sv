module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p;
  logic [63:0] unusedv;
  always_comb begin : blk
    p      = a;
    p[3:0] = b[3:0];
    o      = p;
  end
  always_comb unusedv = a;
endmodule
