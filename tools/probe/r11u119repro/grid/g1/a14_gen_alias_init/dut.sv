package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top(output logic [7:0] o);
  if (1) begin : g
    pkg::u8_t a = 8'h3;
    assign o = a;
  end
endmodule
