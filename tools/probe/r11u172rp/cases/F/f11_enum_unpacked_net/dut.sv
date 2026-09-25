module top import pa::*; (input logic [1:0] i, output logic o);
  e_t a [2];
  assign a[0] = e_t'(i);
  assign o = a[0] == A;
endmodule
