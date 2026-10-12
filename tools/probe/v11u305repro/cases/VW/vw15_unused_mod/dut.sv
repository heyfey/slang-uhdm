// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module unused (input pk::sa_t t);
  wire pk::sa_t sn;
  assign sn = t;
endmodule
module top (input pk::sa_t t, output logic [2:0] o);
  assign o = t.a;
endmodule
