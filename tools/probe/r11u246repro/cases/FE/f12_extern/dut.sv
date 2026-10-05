// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  class c;
    extern function void m();
  endclass
  function void c::m();
    addr_t addrs[];
    foreach (addrs[i]) addrs[i] = i;
  endfunction
endpackage
module top;
endmodule
