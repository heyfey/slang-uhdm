module top import pa::*; (input logic [2:0] i, output logic o);
  s_t a [4];
  assign a[0] = i;
  assign o = f(a[0]);
endmodule
