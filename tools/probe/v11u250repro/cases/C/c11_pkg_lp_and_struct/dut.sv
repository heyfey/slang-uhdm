// § pkgArrTdListing250
// a package array typedef typing a package localparam with a pattern, read by a module at a constant index, a size of [8] with a byte element and a typedef used in a packed struct beside it
package p;
  typedef byte b8_t [8];
  localparam b8_t TBL = '{8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8};
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef s_t sa_t [2];
endpackage
module top(input logic [2:0] i, output byte o, output byte k);
  import p::*;
  b8_t m;
  assign m = TBL;
  assign o = m[i];
  assign k = TBL[3];
endmodule
