// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) (input logic clk);
  T v;
  always_ff @(posedge clk) v <= v + 1;
endinterface
module top(input logic clk, output logic [3:0] o);
  ifc u(clk);
  assign o = u.v;
endmodule
