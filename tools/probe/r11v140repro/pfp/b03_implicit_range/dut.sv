// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter logic [3:0] X = 4'h9;
endpackage
module cc import p::*; #(parameter [3:0] P = X) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o); cc u(.o(o)); endmodule
