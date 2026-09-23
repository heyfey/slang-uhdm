package a;
  typedef logic [1:0] u_t;
endpackage
package q2;
  typedef a::u_t [0:2] r_t;
  typedef struct packed { logic [3:0] pad; r_t [0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [15:0] o);
  assign o = q2::P0;
endmodule
