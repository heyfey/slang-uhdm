package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{pad: 4'h9, U: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11};
endpackage
module dut #(parameter q2::impl_t P = q2::IMPL) (output logic [5:0] o);
  assign o = P.U[1];
endmodule
