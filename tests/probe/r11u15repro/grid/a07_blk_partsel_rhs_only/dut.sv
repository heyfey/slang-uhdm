module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p = a;
    o = p[3:0];
  end
endmodule
