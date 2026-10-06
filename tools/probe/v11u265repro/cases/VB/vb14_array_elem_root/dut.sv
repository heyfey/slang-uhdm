// § cloneBitSelMemberBind265 (fresh: the root is an array element, arr[k].byte_en[z], and a queue element)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f(int k, int z);
  endclass
  function void c::f(int k, int z);
    op_t arr[4];
    op_t qq[$];
    arr[k].byte_en[z] = 1'b1;
    qq[0].byte_en[z] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
