package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
  typedef struct packed { v_t f; logic [1:0] g; } st_t;
endpackage
module dut import p::*; (output logic [5:0] o);
  parameter st_t P = 6'h2a;
  assign o = P;
endmodule
