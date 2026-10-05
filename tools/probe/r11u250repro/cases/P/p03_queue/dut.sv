// § pkgArrTdListing250
package p;
  typedef int q_t[$];
endpackage
module top;
  import p::*;
  q_t q;
  initial q.push_back(1);
endmodule
