module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p, q;
  always_comb begin : blk
    p      = a;
    q[3:0] = b[3:0];
    o      = p ^ q;
  end
endmodule
