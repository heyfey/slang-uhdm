package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = p::D;
  assign o = P;
endmodule
