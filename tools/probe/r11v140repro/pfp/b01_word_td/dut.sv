// § pkgRefFoldClonesMultiDimOnly140
package p;
  typedef logic [31:0] word_t;
  parameter word_t X = 32'd5;
endpackage
module cc import p::*; #(parameter word_t P = X) (output logic [31:0] o);
  assign o = P;
endmodule
module top(output logic [31:0] o); cc u(.o(o)); endmodule
