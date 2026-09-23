package p;
  parameter int W = 40;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 80'h1234_5678_9abc_def0_1234;
endpackage
module sub import p::*; #(parameter s_t P = D) (output logic [79:0] o);
  assign o = P;
endmodule
module dut (output logic [79:0] o);
  sub u (.o(o));
endmodule
