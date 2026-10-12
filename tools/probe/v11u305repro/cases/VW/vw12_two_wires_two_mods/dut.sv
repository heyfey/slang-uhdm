// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module a1 (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
module top (input pk::sa_t t, output logic [2:0] o, output logic [2:0] p);
  wire pk::sa_t   zz;
  assign zz = t;
  assign p = zz.b;
  a1 u (t, o);
endmodule
