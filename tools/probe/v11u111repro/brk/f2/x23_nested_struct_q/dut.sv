package p;
  parameter int W = 8;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t a; logic b; } in_t;
  typedef struct packed { in_t i; k_t n; } s_t;
  localparam s_t D = '0;
endpackage
module dut (output logic [16:0] o);
  parameter p::s_t P = p::D;
  assign o = P;
endmodule
