// § cloneHierArrElemMember478 (an anonymous struct element)
package u;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    struct { int k; bit [63:0] data; } acc[$]; int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a; import u::*; class A; C c; endclass endpackage
module top; import a::*; A o; endmodule
