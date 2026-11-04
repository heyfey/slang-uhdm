// § pkgQualOperandSpanInParam218
package p; localparam int A = 3; localparam int B = 4; endpackage
interface ifc #(parameter int W = 2 * p::A) ();
  logic [W-1:0] d;
endinterface
module top(output logic [5:0] o);
  ifc i();
  assign i.d = '1;
  assign o = i.d;
endmodule
