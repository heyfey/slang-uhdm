// § pkgArrTdListing250
package p;
  parameter int N = 4;
  localparam int W = 8;
  typedef int n_t[N];
  typedef logic [W-1:0] w_t[N-1:0];
  typedef bit [1:0] x_t[2*N];
endpackage
module top;
  import p::*;
  n_t a; w_t b; x_t c;
endmodule
