// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam logic [3:0] C = {2'b1, 2'b0};
  localparam X = 8'(C);
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
