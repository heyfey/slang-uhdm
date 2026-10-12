// § wireScopedTdEndAtType305
module top (input logic [5:0] t, output logic [2:0] o);
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
  wire sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
