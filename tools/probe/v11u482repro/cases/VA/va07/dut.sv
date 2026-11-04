// § cloneArrElemAggOwnCopy482 (queue of a struct with a string member)
package u;
  typedef struct { string s; int data; } op_t;
  function int f(int n);
    op_t acc[$];
    acc.push_back('{s: "x", data: n});
    return acc[0].data;
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
