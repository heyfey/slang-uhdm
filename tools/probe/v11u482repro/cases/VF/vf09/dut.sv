// § cloneFixArrAggElemShared482 (struct also used as a package variable in the importer)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  op_t pv;
  function int g(); pv.k = 1; return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
