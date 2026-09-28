// § ndaRangeQueryFold216 — a hex bound shared by two declarators: $high(a) onto a 3-bit net resizes the shared bound
module dut (output logic [2:0] o, output logic [7:0] o2);
  logic [4'h7:0] a, b;
  wire [2:0] w = $high(a);
  assign o = w;
  assign o2 = b;
endmodule
