// § cloneBitSelMemberBind265 (fresh: the bit select read inside an operation and a condition)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function bit f(int z);
  endclass
  function bit c::f(int z);
    op_t rw;
    if (rw.byte_en[z] && rw.data[0]) return rw.byte_en[z+1] ^ 1'b1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
