package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{pad: 4'h9, U: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11};
endpackage
module dut (output logic [17:0] o);
  assign o = q2::IMPL;
endmodule
