// § cloneFixArrAggElemShared482 (typedef declared inside the function)
package u;
  function int f(int n);
    typedef struct { int k; int data; } lop_t;
    lop_t acc[2];
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
