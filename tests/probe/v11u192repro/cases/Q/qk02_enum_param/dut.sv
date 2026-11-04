// § pkgQualBoundSpanQualifier192
package p;
  typedef enum int {A0 = 0, A1 = 1, A4 = 4} e_t;
endpackage
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y3, output logic [31:0] y4);
  assign y1 = x[p::A4:p::A1];
  assign y3 = x[(p::A4):0];
  always_comb y4 = x[p::A4-1:0];
endmodule
