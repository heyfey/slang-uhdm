package p1;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q2;
  import p1::*;
  typedef struct packed { logic [3:0] pad; row_t [1:0][0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [27:0] o);
  assign o = q2::P0;
endmodule
