package q2;
  typedef logic ut_e;
  typedef ut_e [2:0] row_t;
  typedef struct packed { logic [3:0] pad; row_t [1:0] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [9:0] o);
  assign o = q2::P0;
endmodule
