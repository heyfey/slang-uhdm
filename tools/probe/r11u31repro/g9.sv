package pk;
  typedef logic [1:0] e_t;
endpackage
module dut #(parameter type T = pk::e_t [3:0]) (output T o); assign o = '0; endmodule
