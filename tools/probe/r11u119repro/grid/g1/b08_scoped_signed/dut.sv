package pkg;
  typedef logic signed [7:0] s8_t;
endpackage
module top(output logic [7:0] o);
  pkg::s8_t a = -8'sd3;
  assign o = a;
endmodule
