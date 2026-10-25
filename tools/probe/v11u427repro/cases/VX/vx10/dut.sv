// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.P(4'b1z0x)) u(o[i]);
  end
endmodule
