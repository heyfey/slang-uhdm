package q2;
  typedef logic [1:0] a_t;
  typedef a_t [1:0] b_t;
  typedef b_t [1:0] c_t;
  typedef struct packed { logic [3:0] pad; c_t [1:0] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [19:0] o);
  assign o = q2::P0;
endmodule
