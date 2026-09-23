package q2;
  typedef logic [5:0] row_t;
  typedef union packed { row_t [0:1] U; logic [11:0] w; } u_t;
  localparam u_t P0 = '0;
endpackage
module dut (output logic [11:0] o);
  assign o = q2::P0;
endmodule
