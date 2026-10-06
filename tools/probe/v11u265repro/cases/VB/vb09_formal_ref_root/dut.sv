// § cloneBitSelMemberBind265 (fresh: the root is a ref formal and an output formal)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern task f(ref op_t r, output op_t o, input int z);
  endclass
  task c::f(ref op_t r, output op_t o, input int z);
    r.byte_en[z] = 1'b1;
    o.byte_en[z] = r.byte_en[z];
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
