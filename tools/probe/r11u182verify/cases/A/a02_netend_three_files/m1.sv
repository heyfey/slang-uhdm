module m1 import pa::*; (input logic [4:0] i, output logic o);
  s_t n1 [2];
  assign n1[0] = i;
  assign o = n1[0].y;
endmodule
