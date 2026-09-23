package p;
  parameter int W = 128;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 256'hcebeb96ffe0eced795f8b2cfe23c1e519e4fa08047a6bcfb811b04f0a479006e;
endpackage
module dut (output logic [255:0] o);
  import p::*;
  parameter s_t P = D;
  assign o = P;
endmodule
