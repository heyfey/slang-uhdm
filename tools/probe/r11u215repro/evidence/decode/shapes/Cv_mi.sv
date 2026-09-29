package p;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;
  class c;
    g_int_t m;
  endclass
endpackage
interface ifc;
  import p::*;
endinterface
module m;
  import p::*;
  ifc i();
endmodule
