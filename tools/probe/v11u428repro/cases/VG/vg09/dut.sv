// § uninstGrCaExplicitTopOnly428v
module m #(parameter W) (input [W-1:0] a, output [W-1:0] o, output [W-1:0] q);
  assign q = ~a;
  generate
    genvar i;
    for (i = 0; i < W; i++) begin: g end
    assign o = a;
  endgenerate
endmodule
module top; endmodule
