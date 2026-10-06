// § cloneBitSelMemberBind265 (fresh: the member is an unpacked array, rw.arr[i] an element select)
package p;
  typedef struct { int arr[4]; int data; } op_t;
  class c;
    extern function int f(int z);
  endclass
  function int c::f(int z);
    op_t rw;
    rw.arr[z] = 7;
    return rw.arr[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
