// § defGenConnIpsExprBounds424
`define SEL(b) di[b -: 2]
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4) (input [15:0] di);
  if (1) begin : g
    m #(.w(2)) u (.d(`SEL(W)));
    m #(.w(2)) v (.d(`SEL(7)));
  end
endmodule
