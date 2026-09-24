module top(input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p = a;
    for (int i = 0; i < 2; i++) begin : lb
      p[3:0] = b[3:0];
    end
    o = p;
  end
endmodule
