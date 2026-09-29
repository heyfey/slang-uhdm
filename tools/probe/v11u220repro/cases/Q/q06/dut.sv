// § pkgQualOperandSpanInParam218
package p; localparam int A = 3; endpackage
module top #(parameter logic [7:0] V = {4'(p::A), 4'h0}, parameter int N = -p::A) (output logic [7:0] o, output int n);
  assign o = V;
  assign n = N;
endmodule
