module top(input logic [63:0] a, input logic [63:0] b, input logic s, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p      = a;
    p[3:0] = b[3:0];
    if (s) begin : inner
      o = p;
    end
    else o = 64'd0;
  end
endmodule
