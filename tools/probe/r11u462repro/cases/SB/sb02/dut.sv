// § unitHoistBindsSysCallRhs462
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  parameter int N = $bits(s_t);
  function int f(); return N * 2; endfunction
endpackage
module top;
  import p::*;
  int y;
  initial y = N;
endmodule
