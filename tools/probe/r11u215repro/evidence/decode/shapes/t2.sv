package p;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;
  class c;
    function void set(g_int_t v); endfunction
  endclass
endpackage
module a;
  import p::*;
endmodule
module b;
endmodule
