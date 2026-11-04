// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
`define T pk::sa_t
module top (input pk::sa_t t, output logic [2:0] o);
  wire `T sn;
  assign sn = t;
  assign o = sn.a;
endmodule
