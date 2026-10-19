// § bitSignedElabVar412
module top(output logic [7:0] o);
  typedef bit signed [3:0] sb_t;
  sb_t a;
  bit signed [3:0] b, c;
  assign a = 4'sd3;
  assign b = a;
  assign c = -b;
  assign o = c;
endmodule
