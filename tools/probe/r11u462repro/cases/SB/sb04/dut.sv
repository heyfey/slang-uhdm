// § unitHoistBindsSysCallRhs462
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  parameter int N = $bits(s_t);
  parameter int M = N + 1;
  typedef logic [N-1:0] v_t;
  function int f(int a); return a + N; endfunction
endpackage
import p::*;
module top;
  v_t q;
endmodule
