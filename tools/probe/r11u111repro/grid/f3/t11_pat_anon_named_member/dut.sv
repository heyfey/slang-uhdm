package q2;
  typedef logic [1:0] ut_e;
  typedef struct packed { logic [3:0] pad; ut_e [0:5] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{pad: 4'h9, U: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11};
endpackage
module dut (output logic [17:0] o);
  assign o = q2::IMPL;
endmodule
