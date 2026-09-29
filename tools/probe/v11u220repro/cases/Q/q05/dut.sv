// § pkgQualOperandSpanInParam218
package p; typedef enum logic [1:0] { E0, E1, E2 } e_t; localparam int A = 2; endpackage
module top #(parameter int W = int'(p::E2) + (p::A)) (output logic [W-1:0] o);
  assign o = '0;
endmodule
