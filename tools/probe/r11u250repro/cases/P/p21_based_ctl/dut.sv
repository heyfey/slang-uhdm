// § pkgArrTdListing250 (control: a based literal size, an expression size, a bounded queue and a typedef index stay outside the law)
package p;
  typedef int k_t;
  typedef int x_t[4'd4];
  typedef int y_t[2+2];
  typedef int z_t[$:3];
  typedef int w_t[k_t];
endpackage
module top;
  import p::*;
  x_t a; y_t b; z_t c; w_t d;
endmodule
