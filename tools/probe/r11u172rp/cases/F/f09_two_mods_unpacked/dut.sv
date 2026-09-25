module top import pa::*; (input logic [2:0] i, output logic o, output logic p);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
  sub u (.i(i), .o(p));
endmodule
