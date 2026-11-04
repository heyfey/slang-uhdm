// § cloneBitSelMemberBind265 (fresh: the member is named like a package parameter and a class property)
package p;
  parameter int byte_en = 3;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    int data;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    op_t rw;
    rw.byte_en[z] = 1'b1;
    rw.data[z] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
