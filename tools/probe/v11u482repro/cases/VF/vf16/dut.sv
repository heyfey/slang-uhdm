// § cloneFixArrAggElemShared482 (static local array)
package u;
  typedef struct { int k; int data; } op_t;
  function automatic int f(int n);
    static op_t acc[2];
    acc[0].k = n;
    return acc[1].data;
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
