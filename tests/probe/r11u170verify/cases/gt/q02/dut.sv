// § genTgtLhsLeafOwnName157
module top #(parameter int W = 4) (input logic [1:0] a, output logic [W-1:0] o);
  if (W > 2) begin : B wire [W-1:0] y; end
  assign B.y[3:2] = a;
  assign B.y[0 +: 2] = ~a;
  assign o = B.y;
endmodule
