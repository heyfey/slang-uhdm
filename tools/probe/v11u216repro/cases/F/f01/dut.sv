// § ndaSizeQueryFold216 — $size of an int variable in a net initializer
module dut (output logic [7:0] o);
  int x;
  wire [7:0] w = $size(x);
  assign o = w;
endmodule
