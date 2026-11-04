// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
module sub (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  assign sn = t;
  assign o = sn.b;
endmodule
module top (input pk::sa_t t, output logic [5:0] o);
  sub s0 (t, o[2:0]);
  sub s1 (t, o[5:3]);
endmodule
