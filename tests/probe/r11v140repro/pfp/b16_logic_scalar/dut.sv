// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter logic X = 1'b1;
endpackage
module cc import p::*; #(parameter logic P = X) (output logic o);
  assign o = P;
endmodule
module top(output logic o); cc u(.o(o)); endmodule
