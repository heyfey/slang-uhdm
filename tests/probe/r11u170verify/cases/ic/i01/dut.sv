// § importPatOpCloneParamNamed163
package pa; typedef struct packed { logic p; logic n; } tx_t; parameter tx_t TX_DEF = '{p: 1'b1, n: 1'b0}; endpackage
package pb; typedef struct packed { logic [1:0] v; } rx_t; parameter rx_t RX_DEF = '{v: 2'd2}; endpackage
module gen (output logic [1:0] o, output logic [1:0] o2);
  import pa::*;
  import pb::*;
  assign o = TX_DEF;
  assign o2 = RX_DEF;
endmodule
module top (output logic [1:0] o, output logic [1:0] o2); gen u(.o(o), .o2(o2)); endmodule
