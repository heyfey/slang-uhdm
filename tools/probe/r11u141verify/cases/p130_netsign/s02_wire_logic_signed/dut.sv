// § netSigningTsSpan130
// case s02: the signing keyword follows an explicit data type (wire logic signed)
module top(output logic [7:0] o);
  wire logic signed [7:0] s;
  assign s = 8'sd3;
  assign o = s;
endmodule
