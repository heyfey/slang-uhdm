// § cloneAliasCopyBareName484 (two importers, fixed array of a home alias)
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
package b;
  import u::*;
  function int h(); return f(2); endfunction
endpackage
module top;
  import a::*; import b::*;
  int x, y;
  initial begin x = g(); y = h(); end
endmodule
