typedef logic [1:0] e_t;
module dut (output logic o);
  e_t [3:0] v;
  assign v = '0;
  assign o = ^v;
endmodule
