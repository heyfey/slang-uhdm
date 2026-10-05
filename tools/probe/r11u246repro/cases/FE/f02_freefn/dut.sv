// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  function void m();
    addr_t a[];
    foreach (a[i]) a[i] = i;
  endfunction
endpackage
module top;
endmodule
