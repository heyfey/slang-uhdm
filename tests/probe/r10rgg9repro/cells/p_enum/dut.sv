package pe;
  typedef enum bit {E_OFF, E_ON} e_t;
endpackage
module m
  import pe::*;
#();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (E_OFF) ? {2{sig}} : '0;
endmodule
module top;
  m u_a();
endmodule
