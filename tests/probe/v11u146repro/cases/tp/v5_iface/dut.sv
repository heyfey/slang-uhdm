// § typeParamStructAtKeyword146
interface ifc #(parameter type T = struct packed { logic a; logic [2:0] b; });
  T d;
endinterface
module top(input [3:0] i, output [3:0] o);
  ifc x(); assign x.d = i; assign o = x.d;
endmodule
