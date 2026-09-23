module top(input logic [7:0] a, output logic [7:0] y);
  typedef logic [7:0] t;
  assign y = t'(a);
endmodule
