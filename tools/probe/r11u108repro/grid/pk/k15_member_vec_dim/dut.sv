package q2;
  typedef logic [1:0] ut_e;
  typedef struct packed { logic [3:0] pad; ut_e [0:2] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '0;
endpackage
module dut (output logic [11:0] o);
  localparam q2::impl_t P = q2::IMPL;
  assign o = P;
endmodule
