// § importPatOpCloneParamNamed163
package pa; typedef struct packed { logic p; logic n; } tx_t; parameter tx_t TX_DEF = '{p: 1'b1, n: 1'b0}; endpackage
module gen (output logic [1:0] o [2]);
  import pa::*;
  for (genvar g = 0; g < 2; g++) begin : G
    assign o[g] = TX_DEF ^ 2'(g);
  end
endmodule
module top (output logic [1:0] o [2]); gen u(.o(o)); endmodule
