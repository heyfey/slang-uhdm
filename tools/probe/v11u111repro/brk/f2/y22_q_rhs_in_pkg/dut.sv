package p;
  typedef logic [3:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 8'h21;
endpackage
package r;
  localparam p::s_t E = p::D;
endpackage
module dut (output logic [7:0] o);
  assign o = r::E;
endmodule
