package p;
  parameter int W = 32;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 64'hcebeb96ffe0eced;
endpackage
module dut (output logic [63:0] o);
  parameter p::s_t P = p::D;
  assign o = P;
endmodule
