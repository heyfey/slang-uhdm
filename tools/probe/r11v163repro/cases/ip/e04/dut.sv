// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic [1:0] p; logic n; } tx_t;
  parameter tx_t TX_DEFAULT = '{p: 2'b01, n: 1'b1};
endpackage
import ep::*;
module gen (input tx_t a, output logic x);
  assign x = a.p[0] ^ TX_DEFAULT.n;
endmodule
module top(input logic [2:0] i, output logic o);
  gen u(.a(i), .x(o));
endmodule
