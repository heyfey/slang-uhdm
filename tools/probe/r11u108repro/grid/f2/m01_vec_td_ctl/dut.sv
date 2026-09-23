package q2;
  typedef logic [3:0] v_t;
  typedef struct packed { logic [3:0] pad; v_t [1:0] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [11:0] o);
  assign o = q2::P0;
endmodule
