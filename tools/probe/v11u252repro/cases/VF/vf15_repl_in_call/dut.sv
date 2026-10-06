// § impCastNestedConcatBare252v
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 8'($countones({2{W[1:0]}}));
  localparam Y = 8'(W + V);
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
