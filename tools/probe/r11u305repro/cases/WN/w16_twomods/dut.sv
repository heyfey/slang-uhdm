// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
  typedef union packed { logic [5:0] x; logic [5:0] y; } un_t;
endpackage
module sub (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sx;
  assign sx = t;
  assign o = sx.b;
endmodule
module top (input pk::sa_t t, output logic [2:0] o, output logic [2:0] p);
  wire pk::sa_t sn;
  assign sn = t;
  assign o = sn.a;
  sub u (.t(t), .o(p));
endmodule
