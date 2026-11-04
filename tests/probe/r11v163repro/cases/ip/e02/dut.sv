// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t TX_DEFAULT = '{p: 1'b0, n: 1'b1};
endpackage
package ep2;
  import ep::*;
  parameter tx_t TX2 = '{p: 1'b1, n: 1'b1};
endpackage
module gen import ep2::*; import ep::*; (input tx_t a, output logic x);
  assign x = a.p ^ a.n ^ TX2.p;
endmodule
module top(input logic [1:0] i, output logic o);
  gen u(.a(i), .x(o));
endmodule
