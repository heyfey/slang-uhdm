// § cloneHierArrElemMember478 (a packed union element of a fixed array)
package u;
  typedef union packed { int k; bit [31:0] data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2]; int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a; import u::*; class A; C c; endclass endpackage
module top; import a::*; A o; endmodule
