module top(inout wire [7:0] io, input logic [7:0] a, input logic [7:0] b, output logic [7:0] o);
  logic [7:0] p;
  always_comb begin : blk
    p      = a;
    p[3:0] = b[3:0];
    o      = p ^ io;
  end
endmodule
