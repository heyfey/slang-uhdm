package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{pad: 4'h9, U: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11};
endpackage
module dut (output logic [5:0] o, output logic [5:0] p);
  localparam q2::row_t A = q2::IMPL.U[0];
  localparam q2::impl_t B = q2::IMPL;
  assign o = A;
  assign p = B.U[1];
endmodule
