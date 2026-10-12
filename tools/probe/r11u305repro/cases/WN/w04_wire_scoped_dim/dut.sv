// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module top (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn [2];
  assign sn[0] = t;
  assign o = sn[0].a;
endmodule
