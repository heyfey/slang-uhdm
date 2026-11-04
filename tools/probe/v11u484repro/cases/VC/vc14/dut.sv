// § cloneAliasCopyBareName484 (clone in a package imported by an interface)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
interface ifc;
  import a::*;
  int x;
  initial x = g();
endinterface
module top;
  ifc i();
endmodule
