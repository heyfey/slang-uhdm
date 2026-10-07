// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  localparam int N = $bits(T);
  logic [N-1:0] v;
  assign v = '1;
endinterface
module top(output logic [7:0] o);
  ifc u();
  assign o = u.v;
endmodule
