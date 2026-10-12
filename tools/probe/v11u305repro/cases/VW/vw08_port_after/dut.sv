// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module top (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  assign sn = t;
  later l (sn, o);
endmodule
module later (input pk::sa_t q, output logic [2:0] o);
  pk::sa_t r;
  assign r = q;
  assign o = r.a;
endmodule
