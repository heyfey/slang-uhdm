package p;
  parameter int W = 36;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 72'h1;
  localparam s_t D2 = 72'h2;
endpackage
module sub #(parameter p::s_t P = p::D) (output logic [71:0] o);
  assign o = P;
endmodule
module dut (output logic [71:0] o, output logic [71:0] o2);
  sub u (.o(o));
  sub #(.P(p::D2)) v (.o(o2));
endmodule
