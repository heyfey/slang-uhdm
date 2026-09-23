package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef ut_e [1:0] col_t;
  typedef struct packed { row_t r; col_t c; } s_t;
  localparam s_t S0 = '1;
endpackage
module dut (output logic [9:0] o);
  q2::col_t c;
  assign c = 4'h3;
  assign o = q2::S0 ^ {6'h0, c};
endmodule
