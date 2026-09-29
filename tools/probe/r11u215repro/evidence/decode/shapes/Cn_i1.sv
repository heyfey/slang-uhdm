package p;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;

endpackage
interface ifc;
  import p::*;
endinterface
module m;
  ifc i();
endmodule
