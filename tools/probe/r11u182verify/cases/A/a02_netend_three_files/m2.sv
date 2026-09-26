module m2 import pa::*; (input logic [4:0] i, output logic o);

  s_t n2 [3];
  assign n2[1] = i;
  assign o = n2[1].y;
endmodule
