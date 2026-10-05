// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  typedef bit unsigned [8-1:0] byte_t;
  class c;
    extern function void m1();
    extern function void m2();
  endclass
  function void c::m1();
    addr_t a[];
    foreach (a[i]) a[i] = i;
  endfunction
  function void c::m2();
    byte_t a[string];
    foreach (a[s]) a[s] = 1;
  endfunction
endpackage
module top;
endmodule
