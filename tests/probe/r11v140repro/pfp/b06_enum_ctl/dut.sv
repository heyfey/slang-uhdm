// § pkgRefFoldClonesMultiDimOnly140
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  parameter e_t X = B;
endpackage
module cc import p::*; #(parameter e_t P = X) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o); cc u(.o(o)); endmodule
