// § cloneHierArrElemMember478 (a struct typedef declared in the function)
package u;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    typedef struct { int k; int data; } lt;
    lt acc[2];
    int r;
    r = acc[1].data;
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
