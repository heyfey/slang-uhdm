// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module top (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  wire   pk::sa_t   sm;
  assign sn = t;
  assign sm = t;
  assign o = sn.a ^ sm.b;
endmodule
