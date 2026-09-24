module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o, output logic [63:0] q);
  logic [63:0] p;
  always_comb begin : blk1
    p = a;
    o = p;
  end
  always_comb begin : blk2
    p[3:0] = b[3:0];
    q = p;
  end
endmodule
