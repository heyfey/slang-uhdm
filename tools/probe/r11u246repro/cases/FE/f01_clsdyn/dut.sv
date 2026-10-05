// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  class c;
    function void m();
      addr_t a[];
      a = new[2];
      foreach (a[i]) a[i] = i;
    endfunction
  endclass
endpackage
module top;
endmodule
