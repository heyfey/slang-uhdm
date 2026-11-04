// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t TX_DEFAULT = '{p: 1'b0, n: 1'b1};
endpackage
module gen import ep::*; (input tx_t a, output logic x);
  assign x = a.p ^ TX_DEFAULT.n;
endmodule
module top(input logic [1:0] i, output logic o1, o2);
  gen u(.a(i), .x(o1));
  gen v(.a(i), .x(o2));
endmodule
