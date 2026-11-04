// § genTgtLhsLeafOwnName157
module top(input logic a, output logic o);
  if (1) begin : B wire x; wire [3:0] y; end
  for (genvar k = 0; k < 2; k++) begin : G wire z; end
  assign B.x = a;
  assign B.y[1] = a;
  assign G[1].z = a;
  assign o = B.x;
endmodule
