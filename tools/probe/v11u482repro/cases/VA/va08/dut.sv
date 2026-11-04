// § cloneArrElemAggOwnCopy482 (queue of a struct in a class method of the home package)
package u;
  typedef struct { int k; int data; } op_t;
  class C;
    function int m(int n);
      op_t acc[$];
      acc.push_back('{k: n, data: 1});
      return acc[0].data;
    endfunction
  endclass
  function int f(int n);
    C c = new;
    return c.m(n);
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
