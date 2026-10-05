// § pkgArrTdListing250
package p;
  typedef byte b4_t[4];
  typedef struct { b4_t f; int g; } s_t;
endpackage
module top;
  import p::*;
  s_t s;
endmodule
