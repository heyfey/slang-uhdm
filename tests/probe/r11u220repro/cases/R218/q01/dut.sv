// § pkgQualOperandSpanInParam218
package pk; localparam int A = 3; localparam int B = 5; endpackage
interface ifc #(parameter int P = pk::A * 2 + 1) (); logic [P-1:0] w; endinterface
module top(output int o);
  ifc #() i();
  localparam int Q = int'(pk::B) + ((pk::A));
  assign o = Q;
endmodule
