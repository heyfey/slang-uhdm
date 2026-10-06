// § cloneBitSelMemberBind265 (fresh: the importer package declares its own op_t with a same-named member)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    op_t rw;
    rw.byte_en[z] = 1'b1;
  endfunction
endpackage
package q;
  import p::*;
  typedef struct { bit [3:0] byte_en; } op_t;
endpackage
module top;
  import p::*;
endmodule
