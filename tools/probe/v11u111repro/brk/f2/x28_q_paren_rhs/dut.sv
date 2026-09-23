package p;
  typedef logic [3:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 8'h12;
endpackage
module dut (output logic [7:0] o);
  parameter p::s_t P = (p::D);
  assign o = P;
endmodule
