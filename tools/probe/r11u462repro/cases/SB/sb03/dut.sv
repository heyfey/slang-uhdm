// § unitHoistBindsSysCallRhs462
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  parameter int N = $bits(s_t);
  class C;
    int k = N;
    function int g(); return N; endfunction
  endclass
endpackage
import p::*;
module top;
  C c;
  int y;
  initial y = N;
endmodule
