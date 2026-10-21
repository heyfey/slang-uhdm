// § caAnySysCallLhsTs428
interface ifc(input [3:0] x);
  wire [2:0] c = $countones(x);
endinterface
module top(input [3:0] a);
  ifc u(a);
endmodule
