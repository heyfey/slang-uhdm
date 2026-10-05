// § foreachLocalArrTsOwnListing246
`define AW 64
package p;
  typedef bit unsigned [`AW-1:0] addr_t;
  class c;
    function void m();
      addr_t addrs[];
      foreach (addrs[i]) addrs[i] = i;
    endfunction
  endclass
endpackage
module top;
endmodule
