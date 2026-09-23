package p;
  parameter int W = 40;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 80'h1234;
  localparam s_t E = D;
endpackage
module dut (output logic [79:0] o);
  assign o = p::E;
endmodule
