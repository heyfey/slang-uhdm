// § wireScopedTdEndAtType305
`include "pk.svh"
module top (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
