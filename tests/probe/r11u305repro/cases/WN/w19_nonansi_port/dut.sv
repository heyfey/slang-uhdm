// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
  typedef union packed { logic [5:0] x; logic [5:0] y; } un_t;
endpackage
module top (t, o);
  input wire pk::sa_t t;
  output logic [2:0] o;
  assign o = t.a;
endmodule
