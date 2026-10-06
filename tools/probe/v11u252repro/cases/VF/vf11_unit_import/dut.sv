// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 8'(W + V);
endpackage
import p::*;
module top #(parameter Q = 1) (output logic [7:0] o);
  assign o = X;
endmodule
