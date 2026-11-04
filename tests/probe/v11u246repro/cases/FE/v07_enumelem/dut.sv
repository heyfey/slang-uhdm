// § foreachLocalArrTsOwnListing246
package p;
  typedef enum bit [1:0] {K0, K1, K2} k_e;
  typedef struct packed { bit [64-1:0] a; } s_t;
  class c;
    extern function void m();
  endclass
  function void c::m();
    k_e ka[];
    s_t sa[$];
    foreach (ka[i]) ka[i] = K1;
    foreach (sa[i]) sa[i].a = 0;
  endfunction
endpackage
module top;
endmodule
