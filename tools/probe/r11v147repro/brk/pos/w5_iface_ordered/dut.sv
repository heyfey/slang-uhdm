// § firstOrderedConnBitSelWhole147
interface ifc(input logic c, input logic r);
  logic q;
endinterface
module top(input [3:0] A, B, output logic o);
ifc u(A[1], B[2]);
assign o = u.q;
endmodule
