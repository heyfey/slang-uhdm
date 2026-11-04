package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top(input logic [3:0] i, output logic [7:0] o);
  pkg::u8_t a = {i, i};
  assign o = a;
endmodule
