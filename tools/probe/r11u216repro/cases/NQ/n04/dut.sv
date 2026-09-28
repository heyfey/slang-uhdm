// § ndaRangeQueryFold216 — $high of a ranged parameter in a net initializer
module dut (output logic [7:0] o);
  parameter [6:1] a = 3;
  wire [7:0] w = $high(a);
  assign o = w;
endmodule
