// § tpDefaultCaIfaceKeeps146v
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i);
  T b;
  assign b = i;
endinterface
module top(input [3:0] i);
  ifc x(.i(i));
endmodule
