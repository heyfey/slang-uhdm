package p;
  typedef logic [3:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 8'h12;
endpackage
module sub import p::*; #(parameter s_t P = D) (output logic [7:0] o);
  assign o = P;
endmodule
module dut (output logic [7:0] o);
  sub u (.o(o));
endmodule
