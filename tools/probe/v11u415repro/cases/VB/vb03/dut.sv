// § badCastSizeNoExpr415
interface ifc(input logic [1:0] a);
  logic o;
  assign o = a[0];
endinterface
module top #(parameter W = 2) (input logic [3:0] x);
  for (genvar i = 0; i < 4; i++) begin : g
    ifc u (.a(W'(x[i])));
  end
endmodule
