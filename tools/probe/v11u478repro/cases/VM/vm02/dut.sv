// § cloneHierArrElemMember478 (a packed array of a packed struct in an unpacked array)
package u;
  typedef struct packed { logic [7:0] data; logic k; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t [1:0] acc [2];
    int r;
    r = acc[0][1].data;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top;
  import a::*; import t::*;
  A o; T p;
endmodule
