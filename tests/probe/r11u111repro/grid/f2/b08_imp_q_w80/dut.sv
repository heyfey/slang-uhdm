package p;
  parameter int W = 40;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 80'h1234_5678_9abc_def0_1234;
endpackage
module dut (output logic [79:0] o);
  import p::*;
  parameter s_t P = p::D;
  assign o = P;
endmodule
