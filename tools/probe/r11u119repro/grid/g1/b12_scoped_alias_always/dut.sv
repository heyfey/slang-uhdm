package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top(input logic clk, output logic [7:0] o);
  pkg::u8_t a = 8'h3;
  always_ff @(posedge clk) a <= a + 8'h1;
  assign o = a;
endmodule
