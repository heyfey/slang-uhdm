module sub import pa::*; (input logic [2:0] i, output logic o);
  s_t b [2];
  assign b[0] = i;
  assign o = b[0].y;
endmodule
