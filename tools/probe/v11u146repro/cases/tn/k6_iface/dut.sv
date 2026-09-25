// § tpDefaultCaLhsUnparented146
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T a, b;
  assign b = a;
endinterface
module top(input [3:0] i, output [3:0] o);
  ifc x(); assign x.a = i; assign o = x.b;
endmodule
