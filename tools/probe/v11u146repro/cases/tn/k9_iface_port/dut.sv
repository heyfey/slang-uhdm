// § tpDefaultCaLhsUnparented146
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T a;
endinterface
module top(input [3:0] i);
  ifc x();
  assign x.a = i;
endmodule
