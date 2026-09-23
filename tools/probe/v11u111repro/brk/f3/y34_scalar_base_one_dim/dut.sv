package q2;
  typedef logic ut_e;
  typedef ut_e [0:0] row_t;
  typedef struct packed { row_t r; logic v; } s_t;
  localparam s_t S0 = 2'b10;
endpackage
module dut (output logic [1:0] o);
  assign o = q2::S0;
endmodule
