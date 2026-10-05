// § pkgArrTdListing250
package p;
  typedef int q_t[$];
  typedef byte b_t[2];
  q_t pq;
  b_t pb;
  function automatic int f(q_t a);
    return a.size();
  endfunction
endpackage
module top;
  import p::*;
  int s;
  initial s = f(pq);
endmodule
