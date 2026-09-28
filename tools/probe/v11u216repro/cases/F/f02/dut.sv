// § ndaSizeQueryFold216 — $size of a scalar logic variable in a net initializer
module dut (input logic s, output logic [7:0] o);
  wire [7:0] w = $size(s);
  assign o = w;
endmodule
