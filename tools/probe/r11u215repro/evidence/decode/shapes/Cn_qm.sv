package p;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;

endpackage
package q;
  import p::*;
endpackage
module m;
  import p::*;
endmodule
