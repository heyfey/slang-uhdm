// § cloneFixArrAggElemShared482 (two fixed arrays of two structs in one function)
package u;
  typedef struct { int k; int data; } op_t;
  typedef union { int i; bit [31:0] b; } un_t;
  function int f(int n);
    op_t acc[2];
    un_t uu[3];
    acc[0].k = n;
    uu[1].i = n;
    return acc[1].data + uu[2].i;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
