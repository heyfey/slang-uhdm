package pkg;
  typedef logic [7:0] u8_t;
  localparam u8_t K = 8'h4;
endpackage
module top(output logic [7:0] o);
  pkg::u8_t a = pkg::K + 8'h1;
  assign o = a;
endmodule
