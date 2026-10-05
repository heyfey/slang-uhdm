// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [64-1:0] addr_t;
  localparam int K = 2;
  class c;
    extern function void m(int n);
    extern task t();
  endclass
  function void c::m(int n);
    addr_t addrs[];
    addr_t fixed_a[K];
    addrs = new[n];
    foreach (addrs[i]) addrs[i] = addrs[i][K+:8];
    foreach (fixed_a[j]) fixed_a[j] = {K{1'b1}};
  endfunction
  task c::t();
    addr_t q[$];
    foreach (q[i]) q[i] = K;
  endtask
endpackage
module top;
endmodule
