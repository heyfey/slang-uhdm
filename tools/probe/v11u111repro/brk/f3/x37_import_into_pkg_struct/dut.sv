package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q3;
  import q2::*;
  typedef struct packed { row_t r; logic v; } s_t;
  localparam s_t S0 = 7'h11;
endpackage
module dut (output logic [6:0] o);
  assign o = q3::S0;
endmodule
