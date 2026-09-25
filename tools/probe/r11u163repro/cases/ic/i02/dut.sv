// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic [1:0] p; logic n; } tx_t;
  parameter tx_t TX_DEFAULT = '{p: 2'b10, n: 1'b1};
endpackage
interface bif;
  import ep::*;
  tx_t v;
endinterface
module top(output logic o);
  bif b();
  assign o = b.v.n;
endmodule
