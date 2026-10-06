// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam X = {4'd1, 4'd2};
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
