module top #(parameter int W = 4) (input logic [63:0] a, input logic [63:0] b, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p        = a;
    p[W-1:0] = b[W-1:0];
    o        = p;
  end
endmodule
