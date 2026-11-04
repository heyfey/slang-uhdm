// § cloneHierIdxChainActual482 (downstream: two-dimension struct array and a nested member in a cloned function)
package u;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  typedef struct packed { in_t i; logic [7:0] z; } op_t;
  function automatic logic [7:0] f(input logic [7:0] n);
    op_t acc[2][2];
    acc[0][1].z = n;
    acc[1][0].i.x = n[3:0];
    acc[1][0].i.y = n[7:4];
    return acc[0][1].z + {acc[1][0].i.y, acc[1][0].i.x};
  endfunction
endpackage
package a;
  import u::*;
  function automatic logic [7:0] g(input logic [7:0] n); return f(n); endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  import a::*;
  always_comb o = g(i);
endmodule
