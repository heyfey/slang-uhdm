// § pkgArrTdListing250
package p;
  typedef bit [3:0] d_t[];
endpackage
module top;
  import p::*;
  d_t d;
  initial d = new[2];
endmodule
