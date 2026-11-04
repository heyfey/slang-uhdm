// § cloneBitSelMemberBind265 (the bit select read on a right side)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function bit f(int z);
  endclass
  function bit c::f(int z);
    begin
      op_t rw;
      return rw.byte_en[z];
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
