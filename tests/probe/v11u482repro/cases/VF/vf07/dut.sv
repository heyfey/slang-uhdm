// § cloneFixArrAggElemShared482 (array declared in a nested begin)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    int r;
    begin
      op_t acc[2];
      acc[0].k = n;
      r = acc[1].data;
    end
    return r;
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
