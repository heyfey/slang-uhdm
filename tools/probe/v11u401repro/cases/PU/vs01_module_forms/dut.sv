// § unbasedUntypedElabKeepsLiteral401
module top;
  parameter P0 = '0;
  parameter P1 = '1;
  parameter PZ = 'z;
  parameter PX = 'x;
  logic [3:0] a;
  assign a = P1;
endmodule
