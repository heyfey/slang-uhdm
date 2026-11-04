// § ndaRangeQueryFold216 — $high onto a net narrower than the value (mask?)
module dut (input logic [13:2] i, output logic [1:0] o);
  wire [1:0] w = $high(i);
  assign o = w;
endmodule
