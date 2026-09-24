// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter int X = -3;
endpackage
module cc import p::*; #(parameter logic signed [15:0] P = X) (output logic [15:0] o);
  assign o = P;
endmodule
module top(output logic [15:0] o); cc u(.o(o)); endmodule
