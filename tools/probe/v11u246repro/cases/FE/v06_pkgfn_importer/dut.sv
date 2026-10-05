// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  function automatic int sum();
    addr_t a[3];
    int s;
    foreach (a[i]) s += a[i][7:0];
    return s;
  endfunction
endpackage
module top;
  import p::*;
  int r;
  initial r = sum();
endmodule
