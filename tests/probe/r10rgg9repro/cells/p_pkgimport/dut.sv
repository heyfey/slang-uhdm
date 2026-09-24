package pk2;
  parameter bit PP2 = 0;
endpackage
module m
  import pk2::*;
#(
  parameter bit P = 0
)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (PP2) ? {2{sig}} : '0;
endmodule
module top;
  m u_a();
endmodule
