module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o, output logic [63:0] q);
  logic [63:0] p1, p2;
  always_comb begin : blk
    p1      = a;
    p2      = b;
    p1[3:0] = b[3:0];
    p2[7:4] = a[7:4];
    o       = p1;
    q       = p2;
  end
endmodule
