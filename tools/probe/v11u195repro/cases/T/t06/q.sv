`include "defs.svh"
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t K = '{a: `P(4'd1), b: (4'd2)};
endpackage
