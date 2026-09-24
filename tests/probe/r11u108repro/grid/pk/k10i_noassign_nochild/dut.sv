package p;
  parameter int W = 8;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 16'hbeef;
endpackage
module dut ();
  import p::*;
  parameter s_t P = D;

endmodule
