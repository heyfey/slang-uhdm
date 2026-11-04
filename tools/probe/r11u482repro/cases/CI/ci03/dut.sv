// § cloneFixArrAggElemShared482 (fixed enum array local)
package u;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  function int f(int n);
    e_t acc[3];
    acc[0] = E1;
    return int'(acc[0]) + n;
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
