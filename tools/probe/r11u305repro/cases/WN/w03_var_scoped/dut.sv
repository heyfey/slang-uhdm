// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module top (input pk::sa_t t, output logic [2:0] o);
  pk::sa_t sv;
  assign sv = t;
  assign o = sv.a;
endmodule
