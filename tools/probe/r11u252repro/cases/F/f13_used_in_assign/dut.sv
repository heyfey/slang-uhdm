// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam X = (W+V)'('h0010_0000);
endpackage
module top import p::*; #(parameter Q = 1) ();
  logic [31:0] o;
  assign o = X;
endmodule
