// § defGenConnPsExprBounds424
`define HI 7
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top (input [15:0] di);
  if (1) begin : g
    m #(.w(8)) u (.d(di[`HI:0]));
  end
endmodule
