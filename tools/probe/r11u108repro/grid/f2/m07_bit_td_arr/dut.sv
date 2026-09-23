package q2;
  typedef bit [1:0] b_t;
  typedef b_t [0:2] br_t;
  typedef struct packed { logic [3:0] pad; br_t [0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [15:0] o);
  assign o = q2::P0;
endmodule
