// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
  typedef union packed { logic [5:0] x; logic [5:0] y; } un_t;
endpackage
module top (input pk::un_t t, output logic [5:0] o);
  wire pk::un_t sn;
  assign sn = t;
  assign o = sn.x;
endmodule
