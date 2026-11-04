module top (input logic [7:0] i, output logic [7:0] o);
  typedef logic [07:00] b_t;
  b_t t;
  assign t = i;
  assign o = t;
endmodule
