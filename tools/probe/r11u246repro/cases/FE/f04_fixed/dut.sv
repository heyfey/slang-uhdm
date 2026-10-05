// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  class c;
    function void m();
      addr_t f[4];
      foreach (f[i]) f[i] = i;
    endfunction
  endclass
endpackage
module top;
endmodule
