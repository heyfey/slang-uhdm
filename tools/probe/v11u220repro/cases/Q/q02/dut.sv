// § pkgQualOperandSpanInParam218
package p; localparam int A = 8; localparam int B = 1; endpackage
module top #(parameter int W = $clog2(p::A) + p::B) (output logic [W-1:0] o);
  assign o = '0;
endmodule
