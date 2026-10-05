// § pkgArrTdListing250
package a;
  typedef int q_t[$];
  typedef byte b_t[4];
endpackage
package b;
  import a::*;
  q_t bq;
endpackage
module top;
  import b::*;
  import a::*;
  b_t x;
endmodule
