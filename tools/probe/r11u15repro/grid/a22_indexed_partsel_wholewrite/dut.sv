module top(input logic [63:0] a, input logic [63:0] b, input logic [2:0] i, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p       = a;
    p[i+:4] = b[3:0];
    o       = p;
  end
endmodule
