// § cloneHierArrElemMember478 (a union array)
package u;
  typedef union { int k; int data; } un_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    un_t acc[2];
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
