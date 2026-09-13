module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p [0:1];
  always_comb begin : blk
    p[0]      = a;
    p[0][3:0] = b[3:0];
    o         = p[0];
  end
endmodule
