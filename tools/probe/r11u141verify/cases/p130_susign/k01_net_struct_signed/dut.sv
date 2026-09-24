// § suSigningNotInSpan130
// case k01: an inline packed signed struct as the data type of a wire
module top(output logic [3:0] o);
  wire struct packed signed { logic [1:0] a; logic [1:0] b; } w;
  assign w = 4'b1010;
  assign o = w;
endmodule
