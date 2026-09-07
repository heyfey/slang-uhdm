package pi187;
  typedef int signed  i_is_t;
  parameter i_is_t I_P = -3;
endpackage
module mi187 ();
  localparam int MI = pi187::I_P;
endmodule
