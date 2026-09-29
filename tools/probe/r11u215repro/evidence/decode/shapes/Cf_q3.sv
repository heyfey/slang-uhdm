package p;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;
  function automatic void f(g_int_t v); endfunction
endpackage
package q;
  import p::*;
  class d; int z; endclass
endpackage
module m;
endmodule
