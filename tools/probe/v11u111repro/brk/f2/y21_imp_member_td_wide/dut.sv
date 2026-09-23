package p0;
  typedef logic [39:0] k_t;
endpackage
package p;
  import p0::*;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 80'h77;
endpackage
module dut (output logic [79:0] o);
  import p::*;
  parameter s_t P = D;
  assign o = P;
endmodule
